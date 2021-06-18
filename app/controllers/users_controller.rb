class UsersController < ApplicationController
  before_action :add_client_app


  # adds the app (registered through strava) by its ID
  # in every other Users controller function, can refer to it just as @client
  def add_client_app
    @client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_CLIENT_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )
  end



  def authorize
    # constructs the redirect url for authorization through Strava
    redirect_url = @client.authorize_url(
      redirect_uri: 'http://localhost:3000/redirect',
      approval_propt: 'force', #will change this to auto when I'm done debugging
      response_type: 'code',
      scope: 'activity:write',
      state: 'magic'
    )

    # redirects to the constructed url
    redirect_to redirect_url
  end



  # the url that is returned to after authorization
  # this function adds the new user to the database
  def redirect
    response = @client.oauth_token(code: params.fetch(:code))
    this_user_id = response.athlete.id

    # creates a subscription every time someone signs up (could just be )
    # here will add the token in database



    # updates user is exists, adds if not (should probably put this in model later)
    if User.exists?(this_user_id)
      puts "user is already in the database, adding in new tokens"

      this_user = User.find(this_user_id)
      this_user.update(
        :access_token   => response.access_token,
        :refresh_token  => response.refresh_token,
        :token_exp_date => response.expires_at
      )

    else
      puts "user is not already in the database, now adding them"
      new_user = User.create(
        :id             => response.athlete.id,
        :access_token   => response.access_token,
        :refresh_token  => response.refresh_token,
        :token_exp_date => response.expires_at
      )



    end

    render "general/success.html.erb"

  end


  # will respond to strava webhooks here
  def webhook_response
    # 1) Checks if the webhook is an activity creation - if it isn't, just exits the function (return did nothing as josn or smthg)
    # 2) gets the associated user
    # 3) refreshes any access token if necessary
    # 4) Decides activity name (maybe running quotes, idk yet)
    # 5) makes API call to update activity name to the decided name
  end


  def test_api_call
    puts "about to create activity!"
    my_id = 28783133
    my_user = User.find(my_id)

    # if token is outdated, refreshes it
    if my_user.token_exp_date < Time.now
      puts "Token outdated, now refreshing"
      response = @client.oauth_token(
        refresh_token: my_user.refresh_token,
        grant_type: 'refresh_token'
      )

      my_user.update(
        :access_token   => response.access_token,
        :refresh_token  => response.refresh_token,
        :token_exp_date => response.expires_at
      )

      puts "\n\nnew vals"
      puts response.access_token
      puts response.refresh_token
      puts response.expires_at
      puts "\n\n"
    end






    user_client = Strava::Api::Client.new(
      access_token: my_user.access_token
    )



    activity = user_client.create_activity(
      name: 'Test activity from strava API2',
      type: 'Run',
      start_date_local: Time.now,
      elapsed_time: 1234,
      description: 'Just seeing if I can properly create an activity w/ the Strava API. If this is posted then it worked!',
      distance: 100
    )

    puts activity


    puts "just posted activity!"
  end


end
