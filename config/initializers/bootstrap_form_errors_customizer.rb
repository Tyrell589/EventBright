ActionView::Base.field_error_proc = proc do |html_tag, instance|
  is_label_tag = html_tag =~ /^<label/
  class_attr_index = html_tag.index 'class="' 

  def format_error_message_to_html_list(error_msg)
    html_list_errors = "<ul></ul>"
    if error_msg.is_a?(Array)
      error_msg.each do |msg|
        html_list_errors.insert(-6,"<li>#{msg}</li>")
      end
    else 
      html_list_errors.insert(-6,"<li>#{msg}</li>")
    end
    html_list_errors
  end

  invalid_div =
    "<div class='invalid-feedback'>#{format_error_message_to_html_list(instance.error_message)}</div>"

  
  if class_attr_index && !is_label_tag
    html_tag.insert(class_attr_index + 7, 'is-invalid ')
    html_tag + invalid_div.html_safe
  elsif !class_attr_index && !is_label_tag
    html_tag.insert(html_tag.index('>'), ' class="is-invalid"')
    html_tag + invalid_div.html_safe
  else
    html_tag.html_safe
  end
end