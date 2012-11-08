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

  def action_button(button_type, link_name, path, options = {})
    options[:class] = "btn #{button_type}"
    if options[:hint]
      options[:rel] = "popover"
      options["data-original-title"] = "Hint"
      options["data-content"] = options[:hint]
      options["data-placement"] = "below"
      options[:hint] = nil
    end
    link_to link_name, path, options
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association t(:add_association, :name => t("activerecord.models." + association_name.to_s.singularize)), form_builder, div_class, html_options.merge(:class => "assoc btn")
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association(t(:remove_association, :name => t("activerecord.models." + association_name.to_s.singularize)), form_builder, :class => "assoc btn danger") + tag(:hr)
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
