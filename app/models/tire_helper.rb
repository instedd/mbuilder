module TireHelper
  extend self

  def perform_search(search, restrictions)
    apply_restrictions_to search, restrictions

    yield search if block_given?

    search.perform.results
  end

  def apply_restrictions_to(search, restrictions)
    return unless restrictions.present?
    search.query do
      restrictions.each do |restriction|
        case restriction[:op]
        when :eq
          values = Array(restriction[:value])
          boolean do
            must do |m|
              m.terms restriction[:field], (values.map &:to_s)
            end
          end
        end
      end
    end
  end
end
