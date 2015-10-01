class Telemetry::NumbersByApplicationAndCountryCollector
  def self.collect_stats(period)
    data = {}

    Contact.where('address IS NOT NULL AND created_at < ?', period.end).select('DISTINCT address, application_id').find_each do |contact|
      country_code = InsteddTelemetry::Util.country_code(contact.address)
      if country_code.present?
        data[contact.application_id] ||= Hash.new(0)
        data[contact.application_id][country_code] += 1
      end
    end

    counters = data.inject [] do |r, (application_id, numbers_by_country_code)|
      r.concat(numbers_by_country_code.map do |country_code, count|
        {
          metric: 'numbers_by_application_and_country',
          key: {application_id: application_id, country_code: country_code},
          value: count
        }
      end)
    end

    {counters: counters}
  end
end
