module RecentChangesHelper
  def yaml_load_version(version)
    YAML.safe_load(version.object_changes, %w(Time Date), [], true)
  rescue => e
    Rails.logger.error "Invalid YAML in recent changes version #{version.id}: #{e.message}"
    []
  end

  def associated_link_for(version)
    associated = version.associated_type.constantize.find(version.associated_id)
    if associated.is_a? Conference
      link_to associated.to_s, edit_conference_path
    else
      link_to associated.to_s, associated
    end
  rescue ActiveRecord::RecordNotFound
    "[deleted #{version.associated_type.constantize} with id=#{version.associated_id}]"
  end

  def verb_for(event)
    case event
    when 'destroy'
      t('helpers.has_deleted')
    when('create')
      t('helpers.has_created')
    when('update')
      t('helpers.has_updated')
    else
      "#{event}d"
    end
  end
end
