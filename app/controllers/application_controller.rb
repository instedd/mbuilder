class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_json(object, params={})
    render params.merge(text: object.to_json_oj, content_type: 'text/json')
  end
end
