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

end
