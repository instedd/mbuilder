module TireHelper
  extend self

  def perform_search(search, restrictions)
    apply_restrictions_to search, restrictions

    yield search if block_given?

    search.perform.results
  end

  def apply_restrictions_to(search, restrictions)
    search.query do |query|
      query.boolean("minimum_should_match" => restrictions.size - 1 ) do |boolean|
        restrictions.each do |restriction|
          case restriction[:op]
          when :eq
            values = Array(restriction[:value])
            values.each do |value|
              boolean.should do |q|
                q.match restriction[:field], value
              end
            end
          end
        end
      end
    end
  end
end
