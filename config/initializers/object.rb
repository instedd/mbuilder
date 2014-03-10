class Object
  def not_nil?
    !nil?
  end

  def is_an? object
    is_a? object
  end

  def subclass_responsibility
    raise 'Subclasses must redefine this method'
  end

  def self.subclass_responsibility(*args)
    args.each do |method|
      self.class_eval <<-METHOD
        def #{method}(*args)
          subclass_responsibility
        end
      METHOD
    end
  end

  # This is ugly but is until we store all the values for a given elasticsearch record
  def to_f_if_looks_like_number
    self
  end

  def user_friendly
    self
  end

  def self.generate_equals(*names)
    define_method("==") do |other|
      return false unless self.class == other.class

      names.all? do |name|
        send(name) == other.send(name)
      end
    end
  end
end
