class ExternalServicesController < MbuilderApplicationController
  expose(:external_services) { application.external_services }
  expose(:external_service)

  add_breadcrumb 'External Services'
  set_application_tab :external_services

  def create
    if external_service.save
      render :edit
    else
      render :new
    end
  end

  def edit
    add_breadcrumb external_service.name, external_service
  end

  def update
    if external_service.update_attributes(params[:external_service])
      redirect_to application_external_services_path(application)
    else
      render :edit
    end
  end

  def destroy
    external_service.clean_call_flows
    external_service.destroy
    redirect_to application_external_services_path(application)
  end

  def update_manifest
    begin
      external_service.update_manifest!
      flash[:notice] = 'Manifest successfully updated'
    rescue Exception => ex
      flash[:error] = 'Error updating manifest'
      logger.warn ex
    end
    render :edit
  end
end
