class UsersController < ApplicationController
  before_action :add_client_app


  # adds the app (registered through strava) by its ID
  # in every other Users controller function, can refer to it just as @client
  # might not need this before webhook_response
  def add_client_app
    @client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_CLIENT_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )
  end



  def authorize
    # constructs the redirect url for authorization through Strava
    redirect_url = @client.authorize_url(
      redirect_uri: 'https://runamer.herokuapp.com/redirect',
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

    # creates a subscription every time someone signs up (could just be done once, but this was at least will work)
    subscription = @client.create_push_subscription(
      :callback_url => 'https://runamer.herokuapp.com/webhook_response',
      :verify_token => ENV["VERIFICATION_TOKEN"]
    )
    puts "subscription created successfully"


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
    puts "webhook recieved!"

    # 1) Picks up the webhook and checks that it has the correct verification token
    challenge = Strava::Webhooks::Models::Challenge.new(request.query)
    raise 'Bad Request' unless challenge.verify_token == ENV["VERIFICATION_TOKEN"]


    # 2) Checks if the webhook is an activity creation - if it isn't, just exits the function (return did nothing as josn or smthg)
    if (challenge.object_type == "activity" && challenge.aspect_type == "create" && User.exists?(challenge.owner_id))

      # 3) gets the associated user
      associated_user = User.find(challenge.owner_id)

      # 4) refreshes any access token if outdated (should probably put this in model)
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
      end

      # gets user client
      associated_user_client = Strava::Api::Client.new(
        :access_token => associated_user.access_token
      )


      # 5) Decides activity name (maybe running quotes, idk yet)
      new_activity_name = "TEST ACTIVITY NAME: LETS SEE IF THIS WORKS"


      # 6) makes API call to update activity name to the decided name
      puts "about to make API call to update activity"

      activity = client.update_activity(
        :id => challenge.object_id,
        :name => new_activity_name
      )




    else
      raise 'Request that my webhook will not deal with'

    end
  end




end
