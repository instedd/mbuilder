class MbuilderApplicationController < ApplicationController
  layout "applications"

  before_filter :authenticate_user!

  expose(:application) { current_user.applications.find params[:application_id] }

  before_filter :add_application_breadcrumb

  def add_application_breadcrumb
    add_breadcrumb 'Applications', :applications_path
    add_breadcrumb application.name, application
  end
end
