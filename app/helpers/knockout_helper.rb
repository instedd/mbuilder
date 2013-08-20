module KnockoutHelper
  def ko(hash = {})
    {'data-bind' => kov(hash)}
  end

  def kov(hash = {})
    hash.map do |k, v|
      k = "'#{k}'" if k =~ /\-/
      if v.respond_to? :to_hash
        "#{k}:{#{kov(v)}}"
      elsif k.to_s == 'valueUpdate'
        "#{k}:'#{v}'"
      elsif k.to_s == 'class'
        "'#{k}':#{v}"
      else
        "#{k}:#{v}"
      end
    end.join(',')
  end
end
