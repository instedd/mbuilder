class RecordsController < ApplicationController
  expose(:application)
  expose(:application_table) { application.find_table(params[:table_id]) }
  expose(:record_class) { ElasticRecord.for(application.tire_index.name, params[:table_id]) }
  expose(:record) do
    if params[:action] == "new" || params[:action] == "create"
      record_class.new params[:record]
    else
      record_class.find(params[:id])
    end
  end

  def edit
    @application_tab = :data
    render 'form'
  end

  def new
    render 'form'
  end

  def update
    if record.update_attributes params[:record]
      redirect_to controller: :applications, action: :data
    else
      flash.now[:error] = "Record can't be saved"
      render 'form'
    end
  end

  def create
    if record.save
      redirect_to controller: :applications, action: :data
    else
      flash.now[:error] = "Record can't be saved"
      render 'form'
    end
  end

  def destroy
    @application_tab = :data
    record.destroy
    redirect_to controller: :applications, action: :data
  end
end
