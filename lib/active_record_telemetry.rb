module ActiveRecordTelemetry

  extend ActiveSupport::Concern

  def touch_application_lifespan
    Telemetry::Lifespan.touch_application(self.application)
  end

end

ActiveRecord::Base.send(:include, ActiveRecordTelemetry)
