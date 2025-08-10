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

  def image_box(image, size, options = {} )
    content_tag(:div, class: "image #{size}") do
      image_tag image.url(size), options
    end
  end

  def image_input_box(image)
    content_tag(:div, class: 'd-flex input image small') do
      image_tag image.url(:small)
    end
  end

  def duration_to_time(duration_in_minutes)
    '%02d:%02d' % [duration_in_minutes / 60, duration_in_minutes % 60]
  end

  def icon(name)
    image_tag "icons/#{name}.png"
  end

  def action_button(link_name, path, options = {})
    if options[:hint]
      options['data-bs-toggle'] = 'popover'
      options['data-bs-title'] = t('hint')
      options['data-bs-content'] = options[:hint]
      options['data-bs-placement'] = 'bottom'
      options[:hint] = nil
    end

    link_to link_name, path, options
  end

  def delete_button(path, options = {})
    # Set default options for delete buttons
    default_options = {
      method: :delete,
      class: 'btn btn-sm btn-danger',
      data: {
        controller: "confirm",
        action: "click->confirm#confirm",
        confirm_message_value: t('are_you_sure')
      }
    }

    # Merge user options with defaults, allowing overrides
    merged_options = default_options.deep_merge(options)

    # Handle hint popover like action_button
    if merged_options[:hint]
      merged_options['data-bs-toggle'] = 'popover'
      merged_options['data-bs-title'] = t('hint')
      merged_options['data-bs-content'] = merged_options[:hint]
      merged_options['data-bs-placement'] = 'bottom'
      merged_options[:hint] = nil
    end

    # Use icon-only for delete button
    text = '<i class="bi bi-trash"></i> '.html_safe

    button_to text, path, merged_options
  end

  def add_association_link(association_name, form_builder, div_class, html_options = {})
    text_with_icon = '<i class="bi bi-plus-circle"></i> '.html_safe +
                     t(:add_association, name: t('activerecord.models.' + association_name.to_s.singularize))
    link_to_add_association text_with_icon, form_builder, div_class, html_options.merge(class: 'assoc btn btn-secondary')
  end

  def remove_association_link(association_name, form_builder)
    text_with_icon = '<i class="bi bi-trash"></i> '.html_safe +
                     t(:remove_association, name: t('activerecord.models.' + association_name.to_s.singularize))
    link_to_remove_association(text_with_icon, form_builder, class: 'assoc btn btn-danger')
  end

  def dynamic_association(association_name, title, form_builder, options = {})
    render 'shared/dynamic_association', association_name: association_name, title: title, f: form_builder, hint: options[:hint]
  end


  def languages
    priority_sort_languages(@conference&.language_codes)
  end

  def priority_sort_languages(langs)
    default_lang = I18n.default_locale.to_s
    if langs.include?(default_lang)
      t = langs - [default_lang]
      [default_lang] + t.sort
    else
      langs.sort
    end
  end

  def language_hint(locale)
    l = t("languages.#{locale}")
    return "* #{l}" if locale == I18n.default_locale.to_s

    l
  end

  def language_label(field, locale)
    t("activerecord.attributes.#{field}") + " (#{locale})"
  end

  def translated_input(form_builder, model, attrib, locale)
    p = Mobility.normalize_locale(locale)
    form_builder.input :"#{attrib}_#{p}", label: language_label("#{model}.#{attrib}", locale), hint: language_hint(locale)
  end

  def translated_textbox(form_builder, attrib, locale, label, hint)
    p = Mobility.normalize_locale(locale)
    form_builder.input :"#{attrib}_#{p}", input_html: {rows: 4}, as: :text, label: label, hint: hint
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
    return if conference.call_for_participation.blank?
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

  def markdown_render(arg)
    @md ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
    @md.render(arg)
  end

  def dynamic_association_icon(name)
    case name.to_s.downcase
    when 'classifiers'
      '<i class="bi bi-tags"></i> '.html_safe
    when 'conference_users'
      '<i class="bi bi-people"></i> '.html_safe
    when 'days'
      '<i class="bi bi-calendar"></i> '.html_safe
    when 'event_attachments'
      '<i class="bi bi-paperclip"></i> '.html_safe
    when 'event_people'
      '<i class="bi bi-person"></i> '.html_safe
    when 'im_accounts'
      '<i class="bi bi-chat-left-text"></i> '.html_safe
    when 'languages'
     '<i class="bi bi-translate"></i> '.html_safe
    when 'links'
      '<i class="bi bi-link-45deg"></i> '.html_safe
    when 'notifications'
      '<i class="bi bi-bell"></i> '.html_safe
    when 'phone_numbers'
      '<i class="bi bi-telephone"></i> '.html_safe
    when 'review_metrics'
      '<i class="bi bi-graph-up"></i> '.html_safe
    when 'rooms'
      '<i class="bi bi-door-open"></i> '.html_safe
    when 'tracks'
     '<i class="bi bi-list-task"></i> '.html_safe
    else
      ''
    end
  end

end
