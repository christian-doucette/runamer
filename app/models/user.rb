class User < ApplicationRecord
  def update_user_token!(client)
    if Time.now.to_i >= token_exp_date
      response = client.oauth_token(refresh_token: refresh_token, grant_type: 'refresh_token')
      update(
        access_token: response.access_token,
        refresh_token: response.refresh_token,
        token_exp_date: response.expires_at
      )
    end
  end

  def generate_user_client
    user_client = Strava::Api::Client.new(
      access_token: access_token
    )
  end
end
