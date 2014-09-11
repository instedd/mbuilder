class HomeController < ApplicationController
  def index
    @body_class = "centered #{@body_class}"
  end
end
