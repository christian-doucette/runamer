class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
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
      redirect_uri: 'https://runamer.herokuapp.com/redirect', #
      approval_propt: 'force', #will change this to auto when I'm done debugging
      response_type: 'code',
      scope: 'activity:write,activity:read_all',
      state: 'magic'
    )

    # redirects to the constructed url
    redirect_to redirect_url
  end



  # the url that is returned to after authorization
  # this function adds the new user to the database
  def redirect
    puts "Calling redirect function! a"
    response = @client.oauth_token(code: params.fetch(:code))
    puts "b"
    this_user_id = response.athlete.id
    puts "c"

    # creates webhook client
   # webhook_client = Strava::Webhooks::Client.new(
   #   client_id: ENV["STRAVA_CLIENT_ID"],
   #   client_secret: ENV["STRAVA_CLIENT_SECRET"]
   # )
#
#    # creates a subscription every time someone signs up (could just be done once, but this was at least will work)
#    subscription = webhook_client.create_push_subscription(
#      :callback_url => 'https://runamer.herokuapp.com/webhook_response',
#      :verify_token => ENV["VERIFICATION_TOKEN"]
#    )
#    puts "subscription created successfully"


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
      puts "Response vals for new User:"
      puts response



    end

    render "general/success.html.erb"

  end




  # will respond to strava webhooks here
  def webhook_response
    puts "Webhook response function called"
    # if get request, checks if it is the subscription call
    # if it is, echoes back the hub.challenge token
    if request.get?
      puts "Webhook get request recieved"
      url = request.original_fullpath
      uri = URI.parse(url)
      params = uri.query ? CGI.parse(uri.query) : {}
      params.transform_values! {|value| value[0]}
      puts params

      if params['hub.mode'] == "subscribe" && params['hub.verify_token'] == ENV['VERIFICATION_TOKEN']
		      render json: {'hub.challenge': params['hub.challenge']}, status: :ok
          puts "Successfully subscribed!"
      else
		      raise 'Bad Request'
      end

      # if post request, checks if it is an activity creation post
    elsif request.post?
      puts "Webhook post request recieved. Params are:"
      puts params
      if params['object_type'] == 'activity' && params['aspect_type'] == 'create'
	puts 'This is an activity creation: will attempt to automatically change the name'
	# potentially should make it only change if the name is one of the default ones, so custom names won't be overriden
#	this_user = User.find(params['owner_id']
	if Time.now < this_user.token_exp_date
		puts "Updating out of date user token (#{this_user.token_exp_date} when current time is #{Time.now}"
		response = @client.oauth_token(refresh_token: this_user.refresh_token, grant_type: 'refresh_token')
		this_user.update(
			:access_token   => response.access_token,
			:refresh_token  => response.refresh_token,
			:token_exp_date => response.expires_at
		)
		puts "Just updated user, new info is #{response}"
		
	end
        render json: {}, status: :ok
      else
        render json: {}, status: :ok
      end
    else
      raise 'Bad Request'
    end
  end


  def test_webhook_response

    url = request.original_fullpath
    uri = URI.parse(url)
    params = uri.query ? CGI.parse(uri.query) : {}
    params.transform_values! {|value| value[0]}
    render json: {'hub.challenge': params['hub.challenge']}
  end

end
