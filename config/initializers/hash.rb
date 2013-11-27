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
end
