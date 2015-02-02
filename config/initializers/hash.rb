class Hash
  def to_f_if_looks_like_number
    clone.to_f_if_looks_like_number!
  end

  def to_f_if_looks_like_number!
    each do |key, value|
      self[key] = value.to_f_if_looks_like_number
    end
    self
  end

  def value_in(context)
    res = {}
    each do |key, value|
      res[key] = value.value_in(context)
    end
    res
  end

  def user_friendly
    Hash[map do |key, value|
      [key, value.user_friendly]
    end]
  end
end
