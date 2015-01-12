class HubController < ApplicationController
  before_filter :authenticate_user!

  def api
    render_json hub_api.json("api/" + params[:path])
  end

  private

  def hub_api
    HubClient::Api.trusted(current_user.email)
  end
end
