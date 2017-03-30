require 'active_support/concern'

module SubConference
  extend ActiveSupport::Concern

  included do
    validate :subs_dont_allow_days
    validate :subs_cant_have_subs
  end

  def include_subs
    [self, subs].flatten.uniq
  end

  def events_including_subs
    Event.where(conference: include_subs)
  end

  def rooms_including_subs
    Room.where(conference: include_subs)
  end

  def tracks_including_subs
    Track.where(conference: include_subs)
  end

  def languages_including_subs
    Language.where(attachable: include_subs)
  end

  private

  def subs_dont_allow_days
    return unless sub_conference?
    if Day.where(conference: self).any?
      errors.add(:days, 'are not allowed for conferences with a parent')
      errors.add(:parent, 'may not be set for conferences with days')
    end
  end

  def subs_cant_have_subs
    return unless sub_conference?
    if subs.any?
      errors.add(:subs, 'cannot have sub-conferences and a parent')
      errors.add(:parent, 'may not be set for conferences with a parent')
    end
  end
end
