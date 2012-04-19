module RecentChangesHelper

  def associated_link_for(version)
    begin
      associated = version.associated_type.constantize.find(version.associated_id)
      if associated.is_a? Conference
        link_to associated.to_s, edit_conference_path
      else
        link_to associated.to_s, associated
      end
    rescue
      "[deleted #{version.associated_type.constantize} with id=#{version.associated_id}]"
    end
  rescue ActiveRecord::RecordNotFound
    version.associated_type
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
