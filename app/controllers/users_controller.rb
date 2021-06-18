class UsersController < ApplicationController
  def create
  end


  def authorize
    client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_CLIENT_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )

    # constructs the redirect url for authorization through Strava
    redirect_url = client.authorize_url(
      redirect_uri: 'http://localhost:3000/redirect',
      approval_propt: 'force', #will change this to auto when I'm done debugging
      response_type: 'code',
      scope: 'profile:write',
      state: 'magic'
    )

    # redirects to the constructed url
    redirect_to redirect_url
  end


  def redirect
    client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_CLIENT_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )

    response = client.oauth_token(code: params.fetch(:code))

    # creates a subscription every time someone signs up (could just be )
    # here will add the token in database

    new_user = User.create(
      :user_id        => response.athlete.id,
      :access_token   => response.access_token,
      :refresh_token  => response.refresh_token,
      :token_exp_date => response.expires_at
    )


    render "general/home.html.erb"

  end
end
