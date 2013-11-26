class RecordsController < ApplicationController
  expose(:application)

  def edit
    @application_tab = :data
  end

  def destroy
    @application_tab = :data
    ElasticRecord.for(application.tire_index.name, params[:table_id]).find(params[:id]).destroy
    redirect_to controller: :applications, action: :data
  end
end
