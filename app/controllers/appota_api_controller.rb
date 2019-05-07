class AppotaApiController < ActionController::Base
  before_action :verify_api_token, :check_workspace

  def verify_api_token
    authorization = request.headers['Authorization']
    if authorization.present?
      authorization_data = Base64.decode64(authorization.split(" ")[1].to_s)
      user = authorization_data.split(":")[0]
      apitoken = authorization_data.split(":")[1]
      if user == 'apikey'
        token = Token::Api.where(value: [apitoken, Token::HashedToken.hash_function(apitoken)]).first
        if token.present?
          @current_user_id = token.user_id
          @current_user = User.find(@current_user_id)
          return true
        end
      end
    end
    render status: 403, json: {
      _type: "Error",
      "message": "Unauthorized"
    }
    return false
  end

  def check_workspace
    @workspace_name = (request.headers['X_WORKSPACE_NAME'] || request.headers['HTTP_X_WORKSPACE_NAME']).to_s
    @workspace = Project.where(identifier: @workspace_name).first
    unless @workspace.present?
      render status: 403, json: {
        _type: "Error",
        "message": "Invalid workspace"
      }
    end
  end
end
