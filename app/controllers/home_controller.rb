class HomeController < ApplicationController
  def index
    redirect_to applications_path if current_user
  end
end
