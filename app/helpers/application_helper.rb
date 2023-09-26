module ApplicationHelper
  include Pagy::Frontend
  def bootstrap_class_for_flash(type)
    case type
      when 'info' then 'alert-info'
      when 'success' then 'alert-success'
      when 'danger' then 'alert-danger'
      when 'warning' then 'alert-warning'
      when 'error' then 'alert-danger' #override stripe's "error" flash to work with bootstrap
      when 'notice' then 'alert-success' #override devise's "notice" flash to work with bootstrap
      when 'alert' then 'alert-danger' #override devise's "alert" flash to work with bootstrap
    end
  end

  # Format price
  def pretty_amount(amount_in_cents)
    amount_in_cents == 0 ? 'Free' : number_to_currency(amount_in_cents.to_f / 100, locale: :fr)
  end


  # Event images
  def display_event_images(event, image_class= "")
    if event.images.attached?
      event.images.map { |img| image_tag img.blob, alt: 'default-event-image', class: image_class }
    else
      [image_tag('default-event-image.png', alt: 'default-event-image', class: image_class)]
    end
  end
end
