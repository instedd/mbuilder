class String
  AddressRegexp = %r(^(.*?)://(.*?)$)

  # Returns this string without the protocol part.
  #   'sms://foobar'.without_protocol => 'foobar'
  #   'foobar'.without_protocol => 'foobar'
  def without_protocol
    self =~ AddressRegexp ? $2 : self
  end

  # Returns this string's protocol or '' if it doesn't have one.
  #   'sms://foobar'.protocol => 'sms'
  #   'foobar'.protocol => ''
  def protocol
    self =~ AddressRegexp ? $1 : ''
  end

  # Returns a two element array with the protocol and
  # address of this string.
  def protocol_and_address
    self =~ AddressRegexp ? [$1, $2] : ['', self]
  end
end
