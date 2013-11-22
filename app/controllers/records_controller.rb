class RecordsController < ApplicationController
  expose(:application)

  def edit
    @application_tab = :data
  end
end
