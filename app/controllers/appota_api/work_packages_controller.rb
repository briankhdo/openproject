class AppotaApi::WorkPackagesController < AppotaApiController
  before_action :set_project
  include ActionView::Helpers::NumberHelper

  def index
    # pagination
    offset = params[:offset] || 0
    limit = params[:limit] || 30

    relations = Relation.select("relations.to_id").joins(work_package: :project).where(projects: {id: @project.id}, relations: { relates: 0, duplicates: 0, blocks: 0, follows: 0, includes: 0, requires: 0 }).having("count(*) = 1").group('relations.to_id').order("MIN(work_packages.created_at) ASC")
    total = relations.count.size

    relations = relations.offset(offset).limit(limit)

    work_packages = WorkPackage.where(id: relations.pluck(:to_id)).includes(:status, :type, :author).order(created_at: :asc)
    render json: render_work_packages(work_packages, total)
  end

  protected

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

  def render_work_package work_package
    datetime_formatter = API::V3::Utilities::DateTimeFormatter
    total_children = work_package.children.count
    return {
      _type: 'WorkPackage',
      materialCosts: number_to_currency(work_package.material_costs),
      overallCosts: number_to_currency(work_package.overall_costs),
      id: work_package.id,
      description: work_package.description,
      lockVersion: work_package.lock_version,
      subject: work_package.subject,
      startDate: datetime_formatter.format_datetime(work_package.start_date, allow_nil: true),  
      dueDate: datetime_formatter.format_datetime(work_package.due_date, allow_nil: true),
      estimatedTime: datetime_formatter.format_duration_from_hours(work_package.estimated_hours, allow_nil: true),
      spentTime: datetime_formatter.format_duration_from_hours(work_package.spent_hours, allow_nil: true),
      percentageDone: work_package.done_ratio,
      createdAt: datetime_formatter.format_datetime(work_package.created_at),
      updatedAt: datetime_formatter.format_datetime(work_package.updated_at),
      position: work_package.position,
      storyPoints: work_package.story_points,
      remainingTime: datetime_formatter.format_duration_from_hours(work_package.remaining_hours, allow_nil: true),
      children: total_children > 0 ? render_work_packages(work_package.children.order(created_at: :asc), total_children, false) : [],
      status: work_package.status.as_json(only: [:id, :name]),
      type: work_package.type.as_json(only: [:id, :name]),
      author: work_package.author.as_json(only: [:id, :login, :mail, :firstname, :lastname, :apitoken, :status, :created_on, :updated_on])
    }
  end

  def render_work_packages work_packages, total = 0, collection = true
    response_json = work_packages.map { |v| render_work_package(v) }
    return collection ? {
      _type: "Collection",
      total: total,
      items: response_json
    } : response_json
  end
end
