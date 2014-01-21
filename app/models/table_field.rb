class TableField
  subclass_responsibility :name, :guid, :valid_values, :'self.from_hash'

  def initialize(name, guid, valid_values)
    @name = name
    @guid = guid
    @valid_values = valid_values
  end

  generate_equals :name, :guid, :valid_values

  def valid_value?(value)
    return true if @valid_values.blank?
    value = value.to_f_if_looks_like_number
    valid_values_array.any? { |range| range.cover? value }
  end

  def as_json
    {
      name: name,
      guid: guid,
      valid_values: valid_values,
    }
  end

  def self.from_list(list)
    list.map { |hash| from_hash(hash) }
  end

  private

  def valid_values_array
    cache_valid_values unless @valid_values_array
    @valid_values_array
  end

  def cache_valid_values
    @valid_values_array = []

    pieces = @valid_values.split(",")
    pieces.each do |piece|
      piece = piece.strip
      left, right = piece.split("-", 2)
      if left && right
        left = left.strip
        right = right.strip

        if left.is_number_like? && right.is_number_like?
          left = left.to_f
          right = right.to_f
        end
        @valid_values_array.push(left .. right)
      else
        piece = piece.to_f if piece.is_number_like?
        @valid_values_array.push(piece .. piece)
      end
    end
  end
end
