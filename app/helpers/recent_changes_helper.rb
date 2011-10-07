module RecentChangesHelper

  def associated_link_for(version)
    associated = version.associated_type.constantize.find(version.associated_id)
    if associated.is_a? Conference
      link_to associated.to_s, edit_conference_path
    else
      associated = version.associated_type.constantize.find(version.associated_id)
      link_to associated.to_s, associated
    end
  end

  def verb_for(event)
    case event
    when "destroy"
      "deleted"
    else
      "#{event}d"
    end
  end

end
