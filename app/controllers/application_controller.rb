class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_json(object, params={})
    render params.merge(text: object.to_json_oj, content_type: 'text/json')
  end

  def self.set_application_tab(key)
    before_filter do
      send :set_application_tab, key
    end
  end

  def set_application_tab(key)
    @application_tab = key
  end
end
