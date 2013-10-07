class ResourceMapController < ApplicationController
  before_filter :authenticate_user!

  def collections
    response = resource_map.get "/api/collections.json"
    render text: response.body
  end

  def collection_fields
    response = resource_map.get "/collections/#{params[:id]}/fields.json"
    render text: response.body
  end

  private

  def resource_map
    Guisso.trusted_resource('http://resmap.instedd.org:3002', current_user.email)
  end
end