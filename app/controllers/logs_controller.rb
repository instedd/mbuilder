class LogsController < MbuilderApplicationController
  add_breadcrumb 'Recent activity'
  set_application_tab :recent_activity

  def index
  end
end
