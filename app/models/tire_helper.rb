module TireHelper
  extend self

  def perform_search(search, restrictions)
    apply_restrictions_to search, restrictions
    # puts search.to_curl
    yield search if block_given?

    search.perform.results
  end

  def build_query(restrictions)
    return unless restrictions.present?

    musts = []
    query = { bool: { must: musts } }

    restrictions.each do |restriction|
      case restriction[:op]
      when :eq
        values = Array(restriction[:value]).map &:to_s

        if values.count == 1
          musts << { match: { restriction[:field] => values.first } }
        else
          shoulds = []
          match_any_value = { bool: { should: shoulds, minimum_should_match: 1 } }
          musts << match_any_value
          values.each do |v|
            shoulds << { match: { restriction[:field] => v } }
          end
        end
      end
    end

    query
  end

  def apply_restrictions_to(search, restrictions)
    search.query do |q|
      q.value = build_query(restrictions)
    end
  end
end
