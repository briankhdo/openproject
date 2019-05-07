class AppotaApi::UsersController < AppotaApiController
  def index
    puts "Listing users from '#{@workspace.name}'"
    @users = @workspace.members.map(&:user)
    render json: render_users(@users)
  end

  def create
    user_params = parse_params

    @user = User.create(user_params)

    key_pair = {
      user_id: @user.id
      role_id: user_params[:role_id]
    }
    # add user to members
    project_members = []
    members.each do |key_pair|
      if key_pair[:user_id].present?
        member = Member.create(user_id: key_pair[:user_id], project_id: @workspace.id)
        member.add_and_save_role(key_pair[:role_id])
        project_members << member
      end
    end

    @workspace.members << project_members

    render json: render_user(@user)
  end

  def update
    
  end

  def destroy

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
      user_json = user_json.merge(user.as_json(only: [:id, :login, :firstname, :lastname, :apitoken, :status, :created_on, :updated_on]))
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
end
