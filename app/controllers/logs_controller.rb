class LogsController < ApplicationController
  layout "applications"

  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }

  def index
  end

  private

  def set_tab
    @application_tab = :recent_activity
  end
end
