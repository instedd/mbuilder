class Aggregator
  def initialize(aggregate)
    @aggregate = aggregate
  end

  def apply_to value
    values = Array(value)
    case @aggregate
    when 'count'
      values.length
    when 'total'
      values.sum(&:to_f).user_friendly
    when 'mean'
      sum = values.sum(&:to_f)
      len = values.length
      (len == 0 ? 0 : sum / len).user_friendly
    when 'max'
      values.map(&:to_f).max.user_friendly
    when 'min'
      values.map(&:to_f).min.user_friendly
    when nil
      value
    else
      raise "Unknown aggregate function: #{@aggregate}"
    end
  end
end