module ApplicationHelper
  def management_page_title
    title = ''
    title += @conference.acronym
    if @event.present?
      title += "- #{@event.title}"
    elsif @person.present?
      title += "- #{@person.full_name}"
    end
    title += '- Conference Management'
    title
  end

  def home_page_title
    'frab - home'
  end

  def accessible_conferences
    if current_user.is_admin?
      Conference.creation_order
    elsif current_user.is_crew?
      Conference.accessible_by_crew(current_user).creation_order
    else
      Conference.accessible_by_submitter(current_user)
    end
  end

  def manageable_conferences
    if current_user.is_admin?
      Conference.creation_order
    elsif current_user.is_crew?
      Conference.accessible_by_orga(current_user).creation_order
    else
      []
    end
  end

  def active_class?(*paths)
    'active' if paths.any? { |path| current_page?(path.gsub(/\?.*/, '')) }
  end

  def image_box(image, size)
    content_tag(:div, class: "image #{size}") do
      image_tag image.url(size)
    end
  end

  def image_input_box(image)
    content_tag(:div, class: 'clearfix input image small') do
      image_tag image.url(:small)
    end
  end

  def duration_to_time(duration_in_minutes)
    '%02d:%02d' % [duration_in_minutes / 60, duration_in_minutes % 60]
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  def action_button(button_type, link_name, path, options = {})
    options[:class] = "btn #{button_type}"
    if options[:hint]
      options[:rel] = 'popover'
      options['data-original-title'] = t('hint')
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
    if b
      t('simple_form.yes')
    else
      t('simple_form.no')
    end
  end

  def available_conference_locales
    conference_locales = @conference.language_codes.map(&:to_sym)
    I18n.available_locales & conference_locales
  end

  def by_speakers(event)
    speakers = event.speakers.map { |p| link_to(p.public_name, p) }
    if speakers.present?
      (t('by') + ' ').html_safe + safe_join(speakers, ', ')
    else
      ''
    end
  end

  def show_cfp?(user, conference)
    return unless user
    return true if conference.call_for_participation&.still_running? && conference.days.present?
    return true if user.person.involved_in?(conference)
    false
  end

  def humanized_access_level
    return t('role.admin') if current_user.is_admin?
    return t('role.orga') if current_user.has_role?(@conference, 'orga')
    return t('role.coordinator') if current_user.has_role?(@conference, 'coordinator')
    return t('role.reviewer') if current_user.has_role?(@conference, 'reviewer')
    return t('role.crew') if current_user.is_crew?
    return t('role.submitter') if current_user.is_submitter?
    fail 'should not happen: user without acl'
  end

  def large(attachment)
    attachment.variant(resize_to_fit: [128, 128])
  end

  def small(attachment)
    attachment.variant(resize_to_fit: [32, 32])
  end
end
