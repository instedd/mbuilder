module TireHelper
  extend self

  def perform_search(search, restrictions)
    apply_restrictions_to search, restrictions

    yield search if block_given?

    search.perform.results
  end

  def apply_restrictions_to(search, restrictions)
    restrictions.each do |restriction|
      search.query do
        case restriction[:op]
        when :eq
          values = Array(restriction[:value])
          boolean do
            values.each do |value|
              should { match restriction[:field], value }
            end
          end
        end
      end
    end
  end
end