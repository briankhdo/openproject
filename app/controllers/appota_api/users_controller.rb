class AppotaApi::UsersController < AppotaApiController
  before_action :check_admin, only: [:create, :destroy, :update]

  def index
    puts "Listing users from '#{@workspace.name}'"
    @users = @workspace.members.map(&:user)
    render json: render_users(@users)
  end

  def create
    user_params = parse_params
    role_id = user_params[:role_id] || 4

    user_params.delete :role_id

    User.transaction do 

      @user = User.create(user_params)

      key_pair = {
        user_id: @user.id,
        role_id: role_id
      }
      # add user to members
      member = Member.create(user_id: key_pair[:user_id], project_id: @workspace.id)
      member.add_and_save_role(key_pair[:role_id])
      @workspace.members << member
    end

    render json: render_user(@user)
  end

  def update
    user_params = parse_params
    user_params.delete :role_id

    user_id = params[:id]
    if user_id == 'current'
      user_id = @current_user_id
    else
      user_id = user_id.to_i
      @user = User.find(user_id)
    end

    @user.update(user_params)

    render json: render_user(@user)
  end

  def destroy
    # leave workspace
    user_id = params[:id]
    member = Member.where(user_id: user_id, project_id: @workspace.id).first
    if member.present?
      render json: {
        success: member.destroy.present?
      }
    else
      render json: {
        "_type": "Error",
        message: "Member not found"
      }
    end
  end

  def parse_params
    allowed_params = [:mail, :login, :firstname, :lastname, :password, :role_id]
    request_params = params.permit!.to_h.deep_symbolize_keys
    return request_params.select { |k, v| allowed_params.include? k }
  end

  def render_user user
    if user.errors.present?
      return {
        "_type": "Error",
        message: user.errors
      }
    else
      user_json = {}
      user_json[:_type] = "User"
      user_json[:_workspace] = @workspace.identifier
      user_json = user_json.merge(user.as_json(only: [:id, :login, :mail, :firstname, :lastname, :apitoken, :status, :created_on, :updated_on]))
      user_json[:name] = user.name
      user_json[:api_token] = user.apitoken
      return user_json
    end
  end

  def render_users users
    items = users.map { |user| render_user(user) }

    return {
      "_type": "Collection",
      "_workspace": @workspace.identifier,
      "items": items
    }
  end

  def check_admin
    unless @current_user.admin
      render status: 403, json: {
        _type: "Error",
        "message": "Unauthorized. Permissions required."
      }
    end
  end
end
