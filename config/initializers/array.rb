class Array
  def normalize_for_elasticsearch
    map &:normalize_for_elasticsearch
  end

  def user_friendly
    map &:user_friendly
  end
end
