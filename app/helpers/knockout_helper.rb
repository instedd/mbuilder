module KnockoutHelper
  def ko_link_to(text, click, options = {})
    link_to text, 'javascript:void()', options.merge(ko click: click)
  end

  def ko_text(value)
    "<!-- ko text: #{value} --><!-- /ko -->".html_safe
  end

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
