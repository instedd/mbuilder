class Numeric
  def with_protocol(protocol)
    to_s.with_protocol(protocol)
  end

  def without_protocol
    to_s
  end

  def to_f_if_looks_like_number
    self
  end

  def user_friendly
    self_as_integer = self.to_i
    if self_as_integer == self
      self_as_integer
    else
      self
    end
  end
end
