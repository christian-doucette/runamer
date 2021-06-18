Rails.application.routes.draw do
  get 'users/create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html


# Home page route
get '/', to: 'application#home'



# Users Controller routes
get '/authorize', to: 'users#authorize'
get '/redirect', to: 'users#redirect'
get '/webhook_response', to: 'users#webhook_response'
end
