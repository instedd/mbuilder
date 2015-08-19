class ExternalServicesController < MbuilderApplicationController
  crud_list_options :external_service, title: :name

  expose(:external_services) { application.external_services }
  expose(:external_service)

  add_breadcrumb 'External Services'
  set_application_tab :external_services

  def create
    if external_service.save
      external_service.update_manifest!
      flash.now[:notice] = "External service created"
      render crud_list_append(:external_service, external_service)
    else
      flash.now[:alert] = "External service could not be created"
      render crud_list_new(:external_service, external_service)
    end
  end

  def update
    if external_service.update_attributes(params[:external_service])
      flash.now[:notice] = "External service updated"
    else
      flash.now[:alert] = "External service could not be updated"
    end

    render crud_list_update(:external_service, external_service)
  end

  def destroy
    external_service.destroy
    flash.now[:notice] = "External service removed"
    render crud_list_remove(:external_service, external_service)
  end

  def update_manifest
    begin
      external_service.update_manifest!
      flash.now[:notice] = 'Manifest successfully updated'
    rescue Exception => ex
      flash.now[:alert] = 'Error updating manifest'
      logger.warn ex
    end

    render crud_list_update(:external_service, external_service)
  end
end
