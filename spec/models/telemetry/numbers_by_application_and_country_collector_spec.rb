require 'spec_helper'

describe Telemetry::NumbersByApplicationAndCountryCollector, telemetry: true do

  it 'counts phone numbers by country code and application' do
    application1 = Application.make
    application2 = Application.make

    Contact.make application: application1, address: 'sms://541166667777', created_at: to - 1.day
    Contact.make application: application1, address: 'sms://541155557777', created_at: to - 2.days
    Contact.make application: application1, address: 'sms://85523211344', created_at: to - 5.days
    Contact.make application: application1, address: 'sms://85523211344', created_at: to - 100.days

    Contact.make application: application1, address: 'sms://541155557777', created_at: to - 8.days
    Contact.make application: application1, address: 'sms://541155558888', created_at: to + 1.day
    Contact.make application: application2, address: 'sms://85523211355', created_at: to - 31.days
    Contact.make application: application2, address: 'sms://123', created_at: to - 1.day

    stats = Telemetry::NumbersByApplicationAndCountryCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(3)

    counters.should include({
      metric: 'numbers_by_application_and_country',
      key: {application_id: application1.id, country_code: '54'},
      value: 2
    })
    counters.should include({
      metric: 'numbers_by_application_and_country',
      key: {application_id: application1.id, country_code: '855'},
      value: 1
    })

    counters.should include({
      metric: 'numbers_by_application_and_country',
      key: {application_id: application2.id, country_code: '855'},
      value: 1
    })
  end

end
