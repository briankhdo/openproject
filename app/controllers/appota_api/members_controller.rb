class AppotaApi::MembersController < AppotaApiController
  include AvatarHelper
  before_action :set_project_and_member

  def index
    render json: json_members(@project.members)
  end

  # [{user_id: 1, role_id: 1}]
  def create
    members = params[:members]
    if members.present?
      project_members = []
      members.each do |key_pair|
        if key_pair[:user_id].present?
          member = Member.create(user_id: key_pair[:user_id], project_id: @project.id)
          member.add_and_save_role(key_pair[:role_id])
          project_members << member
        end
      end

      @project.members << project_members

      render json: json_members(@project.members)
    else
      render status: 403, json: {
        _type: "Error",
        message: "Please input members. Example: { members: [ { user_id: 1, role_id: 1 } ] }"
      }
    end
  end

  # update user's role
  def update

  end

  # remove project member
  def destroy
    user_id = params[:user_id]
    user = User.where(id: user_id).first
    if user.present?
      member = Member.where(project_id: @project.id, user_id: user.id).first
      if member.present?
        if member.deletable?
          member.destroy
          render json: {
            _type: "Info",
            message: "Member removed"
          }
        else
          render status: 403, json: {
            _type: "Error",
            message: "Cannot remove project member!"
          }
        end
      else
        render status: 404, json: {
          _type: "Error",
          message: "User ID: #{user_id} was not in project"
        }
      end
    else
      render status: 404, json: {
        _type: "Error",
        message: "User ID: #{user_id} was not found"
      }
    end
  end

private
  def set_project_and_member
    @project_id = params[:project_id]
    if @project_id.to_i != @project_id
      @project = Project.where(identifier: @project_id).first
    else
      @project = Project.where(id: @project_id).first
    end

    unless @project.present?
      render status: 404, json: {
        _type: "Error",
        message: "Project ID: #{@project_id} was not found"
      }
      return false
    end
  end

  def json_members members
    users_roles = members.includes(:user, :roles).map { |v| [v.user, v.roles] }

    members_json = []
    users_roles.each do |user, roles|
      user_json = user.as_json(only: [:id, :firstname, :lastname, :mail])
      user_json[:avatar] = avatar_url(user)
      user_json[:roles] = roles.as_json(only: [:id, :name])
      members_json << user_json
    end
    return {
      _type: "Array",
      "items": members_json
    }
  end
end
