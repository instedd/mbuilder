class Telemetry::NumbersByApplicationAndCountryCollector
  def self.collect_stats(period)
    contacts = Contact.where('address IS NOT NULL AND created_at < ?', period.end)

    {counters: project_counters(contacts).concat(global_counters(contacts))}
  end

  def self.project_counters(contacts)
    project_data = {}

    contacts.select('DISTINCT address, application_id').find_each do |contact|
      country_code = InsteddTelemetry::Util.country_code(contact.address.without_protocol)
      if country_code.present?
        project_data[contact.application_id] ||= Hash.new(0)
        project_data[contact.application_id][country_code] += 1
      end
    end

    counters = project_data.inject [] do |r, (application_id, numbers_by_country_code)|
      r.concat(numbers_by_country_code.map do |country_code, count|
        {
          metric: 'unique_phone_numbers_by_project_and_country',
          key: {project_id: application_id, country_code: country_code},
          value: count
        }
      end)
    end

    counters
  end

  def self.global_counters(contacts)
    global_data = Hash.new(0)

    contacts.select('DISTINCT address').find_each do |contact|
      country_code = InsteddTelemetry::Util.country_code(contact.address.without_protocol)
      if country_code.present?
        global_data[country_code] += 1
      end
    end

    counters =
      global_data.map do |country_code, count|
        {
          metric: 'unique_phone_numbers_by_country',
          key: {country_code: country_code},
          value: count
        }
      end

    counters
  end
end
