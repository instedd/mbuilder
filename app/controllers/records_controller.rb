class RecordsController < ApplicationController
  expose(:application)
  expose(:application_table) { application.find_table(params[:table_id]) }
  expose(:record_class) { ElasticRecord.for(application.tire_index.name, params[:table_id]) }
  expose(:record) do
    if params[:action] == "new" || params[:action] == "create"
      record_class.new params[:record].to_f_if_looks_like_number
    else
      record_class.find(params[:id])
    end
  end

  add_breadcrumb 'Applications', :applications_path


  def edit
    add_breadcrumb application.name, application
    add_breadcrumb 'Data', :application_data
    add_breadcrumb 'Edit record'

    render 'form'
  end

  def new
    add_breadcrumb application.name, application
    add_breadcrumb 'Data', :application_data
    add_breadcrumb 'New record'

    render 'form'
  end

  def update
    add_breadcrumb application.name, application
    add_breadcrumb 'Data', :application_data
    add_breadcrumb 'Edit record'

    if record.update_attributes params[:record].to_f_if_looks_like_number
      redirect_to controller: :applications, action: :data
    else
      flash.now[:alert] = "Record can't be saved"
      render 'form'
    end
  end

  def create
    add_breadcrumb application.name, application
    add_breadcrumb 'Data', :application_data
    add_breadcrumb 'New record'

    if record.save
      redirect_to controller: :applications, action: :data
    else
      flash.now[:alert] = "Record can't be saved"
      render 'form'
    end
  end

  def destroy
    @application_tab = :data
    record.destroy
    redirect_to controller: :applications, action: :data
  end
end
