class ApplicationController < ActionController::Base

	def home
		render "general/home.html.erb"
	end
end
