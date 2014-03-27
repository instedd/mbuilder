class LogsController < MbuilderApplicationController
  add_breadcrumb 'Recent activity'
  set_application_tab :recent_activity
  layout "application"

  def index
  end
end
