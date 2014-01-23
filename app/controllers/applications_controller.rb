class ApplicationsController < ApplicationController
  before_filter :authenticate_user!

  expose(:applications) { current_user.applications }
  expose(:application)

  def show
    @application_tab = :overview
  end

  def create
    if application.save
      redirect_to application
    else
      render :new
    end
  end

  def edit
    @application_tab = :settings
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
    @application_tab = :data
    @data = if application.tire_index.exists?
      (application.tables || []).select {|table| table.is_a? Tables::Local }
    else
      []
    end
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
