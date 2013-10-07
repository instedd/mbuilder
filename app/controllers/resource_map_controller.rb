class ResourceMapController < ApplicationController
  before_filter :authenticate_user!

  def collections
    resource = Guisso.trusted_resource('http://resmap.instedd.org:3002', current_user.email)
    response = resource.get "/api/collections.json"
    render text: response.body
  end
end