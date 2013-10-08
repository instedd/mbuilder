class Array
  def to_f_if_looks_like_number
    map &:to_f_if_looks_like_number
  end

  def user_friendly
    map &:user_friendly
  end
end
