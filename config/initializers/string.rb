class String

  # Adds the given protocol to the string, or replaces
  # it if it already has one.
  def with_protocol(protocol)
    "#{protocol}://#{without_protocol}"
  end

  # Returns this string without the protocol part.
  #   'sms://foobar'.without_protocol => 'foobar'
  #   'foobar'.without_protocol => 'foobar'
  def without_protocol
    self =~ %r(^(.*?)://(.*?)$) ? $2 : self
  end
end
