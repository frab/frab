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

  def action_button(icon_name, link_name, path, options = {})
    options[:class] = "button"
    link_to icon(icon_name) + " " + link_name, path, options
  end

  def add_association_link(text, form_builder, div_class, html_options = {})
    link_to_add_association icon(:add) + " " + text, form_builder, div_class, html_options.merge(:class => "button")
  end

  def remove_association_link(text, form_builder)
    link_to_remove_association icon(:delete) + " " + text, form_builder, :class => "button"
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render "shared/dynamic_association", :association_name => association_name, :title => title, :f => form_builder, :hint => options[:hint]
  end

  def translated_options(collection)
    result = Array.new
    collection.each do |element|
      result << [t("options.#{element}"), element]
    end
    result
  end

  def available_conference_locales
    conference_locales = @conference.language_codes.map {|c| c.to_sym}
    I18n.available_locales & conference_locales
  end

end
