class AppotaApi::VersionsController < AppotaApiController
  before_action :set_project
  before_action :set_version, only: [:show, :update, :destroy]

  def index
    @types = @project.types.order(Arel.sql('position'))
    retrieve_selected_type_ids(@types, @types.select(&:is_in_roadmap?))

    @versions = @project.shared_versions || []
    @versions += @project.rolled_up_versions.visible(@current_user) if @with_subprojects
    @versions = @versions.uniq.sort
    @versions.reject! { |version| version.closed? || version.completed? } unless params[:completed]

    render json: render_versions(@versions)
  end

  def create
    version_data = parse_params
    position = version_data[:position]
    version_data.delete :position
    version_data.delete :id
    version_data[:version_settings_attributes] = [{
      display: position,
      project_id: @project.id
    }]

    @version = @project.versions.build
    version_data.delete('sharing') unless version_data.nil? || @version.allowed_sharings.include?(version_data[:sharing])
    @version.attributes = version_data

    @version.save
    render json: render_version(@version)
  end

  def show
    render json: render_version(@version)
  end

  def update
    version_data = parse_params
    position = version_data[:position]
    version_data.delete :position
    version_data[:version_settings_attributes] = [{
      display: position,
      project_id: @project.id
    }]

    version_data.delete('sharing') unless version_data.nil? || @version.allowed_sharings.include?(version_data[:sharing])
    @version.attributes = version_data

    @version.save
    render json: render_version(@version)
  end

  def destroy
    if @version.fixed_issues.empty?
      @version.destroy
      render json: {
        success: true
      }
    else
      render status: 403, json: {
        success: false,
        message: l(:notice_unable_delete_version)
      }
    end
  end

  private
  
  def parse_params
    # sharing: none, descendants, hierarchy, tree, system
    # position: 1: none, 2: left, 3: right
    allowed_params = [:id, :name, :description, :status, :wiki_page_title, :start_date, :effective_date, :sharing, :position]
    request_params = params.permit!.to_h.deep_symbolize_keys
    return request_params.select { |k, v| allowed_params.include? k }
  end

  def render_version(version)
    if version.errors.present?
      return {
        "_type": "Error",
        message: version.errors
      }
    else
      return {
        _type: version.class.to_s,
        id: version.id,
        name: version.name,
        description: version.description,
        start_date: version.start_date,
        due_date: version.due_date,
        status: version.status,
        created_on: version.created_on,
        updated_on: version.updated_on
      }
    end
  end

  def render_versions(versions)
    return {
      "_type": "Collection",
      "items": versions.map { |v| render_version(v) }
    }
  end

  def retrieve_selected_type_ids(selectable_types, default_types = nil)
    if ids = params[:type_ids]
      @selected_type_ids = (ids.is_a? Array) ? ids.map { |id| id.to_i.to_s } : ids.split('/').map { |id| id.to_i.to_s }
    else
      @selected_type_ids = (default_types || selectable_types).map { |t| t.id.to_s }
    end
  end

  def set_project
    @project_id = params[:project_id]
    if @project_id.present?
      if @project_id.to_i.to_s == @project_id
        @project = Project.where(id: @project_id).first
      else
        @project = Project.where(identifier: @project_id).first
      end
    end
    @project ||= @workspace
  end

  def set_version
    version_id = params[:id]
    @version = Version.where(id: version_id).first
    unless @version.present?
      render status: 404, json: {
        _type: "Error",
        message: "Version ID: #{version_id} was not found"
      }
    end
  end
end
