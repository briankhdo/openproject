class AppotaApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_api_token

  def verify_api_token
    authorization = request.headers['Authorization']
    if authorization.present?
      authorization_data = Base64.decode64(authorization.split(" ")[1].to_s)
      user = authorization_data.split(":")[0]
      apitoken = authorization_data.split(":")[1]
      if user == 'apikey'
        token = Token::Api.where(value: apitoken).first
        if token.present?
          @current_user_id = token.user_id
          @current_user = User.find(@current_user_id)
          return true
        end
      end
    end
    render status: 403, json: {}
    return false
  end
end
