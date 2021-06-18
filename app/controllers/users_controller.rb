class UsersController < ApplicationController
  def create
  end


  def authorize
    client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_CLIENT_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )
    
    redirect_url = client.authorize_url(
      redirect_uri = '/redirect',
      approval_propt: 'force',
      response_type: 'code',
      scope: 'profile:write',
      state: 'magic'
    )
  end 


  def redirect
    response = client.oauth_token(code: params.fetch(:code))
    # here will renew the token in database
    
    
  end
end
