class AppotaApi::ProjectsController < AppotaApiController
  def create
    # assign workspace automatically
    unless parse_params[:parent_id].present?
      parse_params[:parent_id] = @workspace.id
    end
    new_project = Project.create(parse_params)
    new_project.enabled_module_names += ["reporting_module", "costs_module"]
    render json: render_project(new_project)
  end

  def update
    allowed_params = [:name, :description, :identifier, :is_public, :parent_id, :status]
    @project_id = params[:id]
    if @project_id.to_i.to_s != @project_id
      @project = Project.where(identifier: @project_id).first
    else
      @project = Project.where(id: @project_id).first
    end
    if @project.present?
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
      @project = Project.where(identifier: @project_id).first
    else
      @project = Project.where(id: @project_id).first
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
end