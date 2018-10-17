require 'active_support/concern'

module SubConference
  extend ActiveSupport::Concern

  included do
    validate :subs_dont_allow_days
    validate :subs_cant_have_subs

    before_save :update_dates_from_conference
  end

  def include_subs
    [self] + subs
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
    return if Day.where(conference: self).empty?
    errors.add(:days, 'are not allowed for conferences with a parent')
    errors.add(:parent, 'may not be set for conferences with days')
  end

  def subs_cant_have_subs
    return unless sub_conference?
    return if subs.empty?
    errors.add(:subs, 'cannot have sub-conferences and a parent')
    errors.add(:parent, 'may not be set for conferences with a parent')
  end

  def update_dates_from_conference
    return unless sub_conference?
    days = Day.where(conference_id: parent.id)
    self.start_date = days.pluck(:start_date).min
    self.end_date = days.pluck(:end_date).min
  end
end
