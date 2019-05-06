class AppotaApi::CostlogController < AppotaApiController
  def create
    user_id = @current_user_id
    project_id = params[:project_id]
    work_package_id = params[:work_package_id]
    cost_type_id = params[:cost_type_id]
    units = params[:units].to_f
    spent_on = params[:spent_on]
    comments = params[:comments].to_s

    @work_package = WorkPackage.where(id: work_package_id).first
    unless @work_package.present?
      render status: 404, json: {
        _type: "Error",
        message: "Work Package ID: #{word_package_id} was not found"
      }
      return false
    end

    @project = @work_package.project

    @cost_type = CostType.where(id: cost_type_id).first

    @cost_entry = CostEntry.new.tap do |ce|
      ce.project  = @project
      ce.work_package = @work_package
      ce.cost_type = @cost_type if @cost_type.present?
      ce.user = @current_user
      ce.spent_on = Date.today
      ce.spent_on = Date.parse(spent_on) if spent_on.present?
      ce.units = units
      ce.comments = comments
    end

    if @cost_entry.save
      render json: {
        _type: "Info",
        message: "Log completed"
      }
    else
      render status: 403, json: {
        "_type": "Error",
        message: @cost_entry.errors
      }
    end
  end
end
