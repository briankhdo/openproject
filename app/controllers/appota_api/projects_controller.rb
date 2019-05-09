class AppotaApi::ProjectsController < AppotaApiController

  def index
    # list project by current workspace
    status = params[:status]
    @projects = @workspace.children
    if status.present?
      @projects = @projects.where(status: status)
    end
    render json: render_projects(@projects.visible(@current_user))
  end

  def show

    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = Project.where(identifier: @project_id).first
    else
      @project = Project.where(id: @project_id).first
    end
    if @project.present?
      @users_by_role = @project.users_by_role
      @subprojects = @project.children.visible(@current_user)
      @news = @project.news.limit(5).includes(:author, :project).order("#{News.table_name}.created_on DESC")
      @types = @project.rolled_up_types

      cond = @project.project_condition(Setting.display_subprojects_work_packages?)

      @open_issues_by_type = WorkPackage
                             .visible(@current_user).group(:type)
                             .includes(:project, :status, :type)
                             .where(["(#{cond}) AND #{Status.table_name}.is_closed=?", false])
                             .references(:projects, :statuses, :types)
                             .count
      @total_issues_by_type = WorkPackage
                              .visible(@current_user).group(:type)
                              .includes(:project, :status, :type)
                              .where(cond)
                              .references(:projects, :statuses, :types)
                              .count

      project_json = render_project(@project)
      project_json[:users_by_role] = @users_by_role.as_json(only: [:id, :login, :mail, :firstname, :lastname, :apitoken, :status, :created_on, :updated_on])
      project_json[:sub_projects] = render_projects(@subprojects, false)
      project_json[:news] = @news.as_json
      project_json[:types] = @types.as_json(only: [:name, :position, :is_in_roadmap, :is_milestone, :is_default, :color_id, :created_at, :updated_at, :is_standard])
      project_json[:open_issues_by_type] = @open_issues_by_type.as_json
      project_json[:total_issues_by_type] = @total_issues_by_type.as_json

      render json: project_json
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
    end
  end

  def create
    # assign workspace automatically
    project_params = parse_params.to_h
    unless project_params[:parent_id].present?
      project_params[:parent_id] = @workspace.id
    end
    new_project = Project.create(project_params)
    new_project.enabled_module_names += ["reporting_module", "costs_module"]
    render json: render_project(new_project)
  end

  def update
    allowed_params = [:name, :description, :identifier, :is_public, :parent_id, :status]
    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = @workspace.children.where(identifier: @project_id).first
    else
      @project = @workspace.children.where(id: @project_id).first
    end
    if @project.present?
      # check parent is workspace
      if @project.parent_id == @workspace.id
        # prevent changing parent_id
        allowed_params -= [:parent_id]
      end
      update_params = parse_params.select { |k, v| allowed_params.include? k }
      @project.update(update_params)
      render json: render_project(@project)
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
    end
  end

  def destroy
    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = @workspace.children.where(identifier: @project_id).first
    else
      @project = @workspace.children.where(id: @project_id).first
    end
    if @project.present?
      @project.archive
      render json: render_project(@project)
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
    end
  end

  def unarchive
    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = @workspace.children.where(identifier: @project_id).first
    else
      @project = @workspace.children.where(id: @project_id).first
    end

    if @project.present?
      @project.update(status: 1)
      render json: render_project(@project)
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
    end
  end

  def roadmap

    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = @workspace.children.where(identifier: @project_id).first
    else
      @project = @workspace.children.where(id: @project_id).first
    end

    if @project.present?

      @types = @project.types.order(Arel.sql('position'))
      retrieve_selected_type_ids(@types, @types.select(&:is_in_roadmap?))
      @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_work_packages? : (params[:with_subprojects].to_i == 1)

      project_ids = @with_subprojects ? @project.self_and_descendants.map(&:id) : [@project.id]

      @versions = @project.shared_versions || []
      @versions += @project.rolled_up_versions.visible(@current_user) if @with_subprojects
      @versions = @versions.uniq.sort
      @versions.reject! { |version| version.closed? || version.completed? } unless params[:completed]

      @issues_by_version = {}
      unless @selected_type_ids.empty?
        @versions.each do |version|
          issues = version.fixed_issues.visible(@current_user).includes(:project, :status, :type, :priority)
                   .where(type_id: @selected_type_ids, project_id: project_ids)
                   .order("#{Project.table_name}.lft, #{::Type.table_name}.position, #{WorkPackage.table_name}.id")
          @issues_by_version[version] = issues
        end
      end
      @versions.reject! { |version| !project_ids.include?(version.project_id) && @issues_by_version[version].blank? }

      render json: render_versions(@versions, @issues_by_version)

    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
    end
  end

  def parse_params
    allowed_params = [:id, :name, :description, :is_public, :parent_id, :identifier, :status]
    request_params = params.permit!.to_h.deep_symbolize_keys
    return request_params.select { |k, v| allowed_params.include? k }
  end

  def render_project project
    if project.errors.present?
      return {
        "_type": "Error",
        message: project.errors
      }
    else
      project_json = {}
      project_json[:_type] = "Project"
      project_json = project_json.merge(project.as_json(only: [:id, :identifier, :name, :description, :status, :created_on, :updated_on]))
      return project_json
    end
  end

  def render_projects projects, collection = true
    ap projects
    projects = projects.map { |project| render_project(project) }

    return collection ? {
      "_type": "Collection",
      "_workspace": @workspace.identifier,
      "items": projects
    } : projects
  end

  def render_versions versions, issues_by_version
    response_json = []
    versions.each do |version|
      version_json = version.as_json
      version_json[:issues] = issues_by_version[version].as_json
      version_json[:wiki_content] = version.wiki_page.content if version.wiki_page
      response_json << version_json
    end
    return {
      "_type": "Collection",
      "items": response_json
    }
  end

private
  def retrieve_selected_type_ids(selectable_types, default_types = nil)
    if ids = params[:type_ids]
      @selected_type_ids = (ids.is_a? Array) ? ids.map { |id| id.to_i.to_s } : ids.split('/').map { |id| id.to_i.to_s }
    else
      @selected_type_ids = (default_types || selectable_types).map { |t| t.id.to_s }
    end
  end
end
