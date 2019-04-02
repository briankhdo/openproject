class AppotaApi::ProjectsController < AppotaApiController
  def create
    new_project = Project.create(parse_params)
    render json: render_project(new_project)
  end

  def update
    allowed_params = [:name, :description, :identifier, :status]
    project_id = params[:id]
    project = Project.where("id = ? OR identifier = ?", project_id).first
    if project.present?
      update_params = parse_params.select { |k, v| allowed_params.include? k }
      project.update(update_params)
      render json: render_project(project)
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{project_id} was not found"
      }
    end
  end

  def destroy
    project_id = params[:id]
    project = Project.where("id = ? OR identifier = ?", project_id).first
    if project.present?
      project.archive
      render json: render_project(project)
    else
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{project_id} was not found"
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
      project_json = project_json.merge(project.as_json(only: [:id, :identifier, :name, :description, :created_at, :updated_at]))
      return project_json
    end
  end
end
