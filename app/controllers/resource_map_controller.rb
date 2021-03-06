class ResourceMapController < ApplicationController
  before_filter :authenticate_user!

  def collections
    collections = resource_map.collections.all
    collections_json = collections.map { |col| {id: col.id, name: col.name} }
    render_json collections_json
  end

  def collection_fields
    fields = resource_map.collections.find(params[:id]).fields
    fields_json = fields.map { |field| {id: field.id, name: field.name, kind: field.kind} }
    render_json fields_json
  end

  private

  def resource_map
    ResourceMap::Api.trusted(current_user.email, ResourceMap::Config.url, ResourceMap::Config.use_https)
  end
end
