module Telemetry::Lifespan
  def self.touch_application(application)
    if application.present?
      InsteddTelemetry.timespan_update('application_lifespan', {application_id: application.id}, application.created_at, Time.now.utc)

      touch_user(application.user)
    end
  end

  def self.touch_user(user)
    InsteddTelemetry.timespan_update('account_lifespan', {user_id: user.id}, user.created_at, Time.now.utc) if user.present?
  end
end
