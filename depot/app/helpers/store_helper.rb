module StoreHelper
  # Generate a <div> which is hidden if condition evaluates to true
  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes['style'] = "display: none"
    end
    content_tag("div", attributes, &block)
end