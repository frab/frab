module ApplicationHelper
  def accessible_conferences
    conferences = []
    if current_user.is_crew?
      conferences = Conference.accessible_by_crew(current_user).order('created_at DESC')
    else
      conferences = Conference.order('created_at DESC')
    end
    conferences
  end

  def manageable_conferences
    conferences = []
    if current_user.is_crew?
      conferences = Conference.accessible_by_orga(current_user).order('created_at DESC')
    else
      conferences = Conference.order('created_at DESC')
    end
    conferences
  end

  def active_class?(*paths)
    active = false
    paths.each { |path| active ||= current_page?(path) }
    active ? 'active' : nil
  end

  def image_box(image, size)
    content_tag(:div, class: "image #{size}") do
      image_tag image.url(size)
    end
  end

  def duration_to_time(duration_in_minutes)
    minutes = sprintf('%02d', duration_in_minutes % 60)
    hours = sprintf('%02d', duration_in_minutes / 60)
    "#{hours}:#{minutes}"
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  def action_button(button_type, link_name, path, options = {})
    options[:class] = "btn #{button_type}"
    if options[:hint]
      options[:rel] = 'popover'
      options['data-original-title'] = 'Hint'
      options['data-content'] = options[:hint]
      options['data-placement'] = 'below'
      options[:hint] = nil
    end
    link_to link_name, path, options
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    link_to_add_association t(:add_association, name: t('activerecord.models.' + association_name.to_s.singularize)), form_builder, div_class, html_options.merge(class: 'assoc btn')
  end

  def remove_association_link(association_name, form_builder)
    link_to_remove_association(t(:remove_association, name: t('activerecord.models.' + association_name.to_s.singularize)), form_builder, class: 'assoc btn danger') + tag(:hr)
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render 'shared/dynamic_association', association_name: association_name, title: title, f: form_builder, hint: options[:hint]
  end

  def translated_options(collection)
    result = []
    collection.each do |element|
      result << [t("options.#{element}"), element]
    end
    result
  end

  def t_boolean(b)
    b ?
      t("simple_form.yes") :
      t("simple_form.no")
  end

  def available_conference_locales
    conference_locales = @conference.language_codes.map(&:to_sym)
    I18n.available_locales & conference_locales
  end

  def by_speakers(event)
    speakers = event.speakers.map { |p| link_to p.public_name, p }
    if not speakers.empty?
      "by #{speakers.join(', ')}".html_safe
    else
      ''
    end
  end
end
