module ApplicationHelper

  def image_box(image, size)
    content_tag(:div, :class => "image #{size}") do
      image_tag image.url(size)
    end
  end

  def duration_to_time(duration_in_minutes)
    minutes = sprintf("%02d", duration_in_minutes % 60)
    hours = sprintf("%02d", duration_in_minutes / 60)
    "#{hours}:#{minutes}"
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  def add_association_link(text, form_builder, div_class)
    link_to_add_association icon(:add) + " " + text, form_builder, div_class, :class => "button"
  end

  def remove_association_link(text, form_builder)
    link_to_remove_association icon(:delete) + " " + text, form_builder, :class => "button"
  end

end
