class TableField
  attr_accessor :name
  attr_accessor :guid
  attr_accessor :valid_values

  def initialize(name, guid, valid_values)
    @name = name
    @guid = guid
    @valid_values = valid_values
  end

  def valid_value?(value)
    return true if @valid_values.blank?

    cache_valid_values

    value = value.to_f if is_number_like?(value)

    @valid_values_array.any? { |range| range.include? value }
  end

  def as_json
    {
      name: name,
      guid: guid,
      valid_values: valid_values,
    }
  end

  def self.from_list(list)
    list.map { |hash| TableField.from_hash(hash) }
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values']
  end

  private

  def cache_valid_values
    @valid_values_array = []

    pieces = @valid_values.split(",")
    pieces.each do |piece|
      piece = piece.strip
      left, right = piece.split("-", 2)
      if left && right
        left = left.strip
        right = right.strip

        if is_number_like?(left) && is_number_like?(right)
          left = left.to_f
          right = right.to_f
        end
        @valid_values_array.push(left .. right)
      else
        piece = piece.to_f if is_number_like?(piece)
        @valid_values_array.push(piece .. piece)
      end
    end
  end

  def is_number_like?(string)
    string =~ /\d+(\.\d+)?/
  end
end
