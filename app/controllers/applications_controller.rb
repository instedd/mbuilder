class ApplicationsController < ApplicationController
  layout "applications", except: :index
  layout "application", only: :index
  add_breadcrumb 'Applications', :applications_path

  before_filter :authenticate_user!

  expose(:applications) { current_user.applications }
  expose(:application)

  def show
    add_breadcrumb application.name, application
    add_breadcrumb 'Overview'
    set_application_tab :overview
  end

  def create
    if application.save
      redirect_to application
    else
      render :new
    end
  end

  def edit
    add_breadcrumb application.name, application
    add_breadcrumb 'Settings'
    set_application_tab :settings
  end

  def update
    if application.update_attributes(params[:application])
      redirect_to application
    else
      render :edit
    end
  end

  def destroy
    application.destroy
    redirect_to applications_path
  end

  def data
    add_breadcrumb application.name, application
    add_breadcrumb 'Data'
    set_application_tab :data

    @data = application.local_tables
  end

  def export
    filename = "#{application.name}-#{application.id}-#{application.updated_at.strftime("%F")}.mba"
    file = Tempfile.new filename
    begin
      application.export file
    ensure
      file.close
    end
    send_file file.path, filename: filename
  end

  def import
    application.import! File.read(params[:mba].tempfile.path)
    flash.notice = 'Application imported'
    redirect_to application
  end

  def request_api_token
    @token = Guisso.generate_bearer_token current_user.email
    @url_params = { access_token: @token }
    render layout: false
  end
end
