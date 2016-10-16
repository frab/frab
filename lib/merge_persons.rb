# frozen_string_literal: true
class MergePersons
  def initialize(keep_last_updated = true)
    @keep_last_updated = keep_last_updated
  end

  def combine!(keep, kill)
    return merge_persons(kill, keep) if retain_second_person?(keep, kill)
    merge_persons(keep, kill)
  end

  private

  def retain_second_person?(keep, kill)
    @keep_last_updated && kill.newer_than?(keep)
  end

  def merge_persons(keep, kill)
    # Merge or move user model
    if keep.user.present?
      keep.user = merge_users(keep.user, kill.user) if kill.user.present?
    else
      keep.user = kill.user
      kill.user = nil
    end

    # Get list of all conferences for which keep already has set the availabilities, then only
    # import availabilities for the others
    keep_cons = keep.availabilities.select(:conference_id).uniq
    kill.availabilities.all do |avail|
      next if keep_cons.include? avail.conference_id
      avail.update_attributes(person_id: keep.id)
    end

    # Merge ticket. Orphan ticket in kill, if both have one
    if keep.ticket.nil?
      keep.ticket = kill.ticket
      kill.ticket = nil
    end

    # Merge languages
    kill.languages.all do |lang|
      keep.languages << lang unless keep.languages.include? lang
    end

    # Merge event_person, if the person does not already have the same role in the same event
    kill.event_people.all do |event_person|
      next if keep.event_people.find_by(eventid: event_person.event_id, role: event_person.role)
      event_person.update_attributes(person_id: keep.id)
    end

    # steal all members that need no special treatment
    kill.event_ratings.all { |rating| rating.update_attributes(person_id: keep.id) }
    kill.im_accounts.all { |im| im.update_attributes(person_id: keep.id) }
    kill.links.all { |link| link.update_attributes(associated_id: keep.id) }
    kill.phone_numbers.all { |phone| phone.update_attributes(person_id: keep.id) }

    # update conflicts on all associated events
    keep.events.all(&:update_conflicts)

    # remove merged user and save the one to keep
    kill.destroy
    keep.save!
    keep
  end

  def merge_users(keep, kill)
    keep, kill = kill, keep if @keep_last_updated && kill.newer_than?(keep)

    # merge conference users, if both were in the same conference, keep the one from keep
    kill.conference_users.all.each do |u|
      next if u.conference.nil?
      collision = keep.conference_users.find_by conference_id: u.conference_id
      if collision
        if ConferenceUser::ROLES.index(u.role) > ConferenceUser::ROLES.index(collision.role)
          collision.update_attributes role: u.role
        end
        u.destroy
      else
        u.update_attributes user_id: keep.id
      end
    end

    # get rid of older user and return the one we keep
    kill.destroy
    keep.save
    keep
  end
end
