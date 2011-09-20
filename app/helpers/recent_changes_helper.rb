module RecentChangesHelper

  def associated_link_for(version)
    associated = version.associated_type.constantize.find(version.associated_id)
    link_to associated.to_s, associated
  end

end
