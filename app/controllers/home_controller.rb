class HomeController < ApplicationController
  after_filter :intercom_shutdown, :only => [:index]

  def index
  end

  def test
  end

  protected
  def intercom_shutdown
    IntercomRails::ShutdownHelper.intercom_shutdown(session, cookies, request.domain)
  end
end
