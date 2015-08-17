class CreateIndexes < ActiveRecord::Migration
  def up
    # missing from schema.rb
    unless index_exists? :users, :confirmation_token, unique: true
      add_index :users, :confirmation_token, name: "index_users_on_confirmation_token", unique: true
    end

    unless index_exists? :users, :email, unique: true
      add_index :users, :email, name: "index_users_on_email", unique: true
    end

    unless index_exists? :users, :reset_password_token, unique: true
      add_index :users, :reset_password_token, name: "index_users_on_reset_password_token", unique: true
    end

    unless index_exists? :versions, [:item_type, :item_id]
      add_index :versions, [:item_type, :item_id], name: "index_versions_on_item_type_and_item_id"
    end

    # foreign keys
    add_index :availabilities, :person_id, name: "index_availabilities_on_person_id"
    add_index :availabilities, :conference_id, name: "index_availabilities_on_conference_id"
    add_index :call_for_papers, [:start_date, :end_date], name: "index_call_for_papers_on_dates"
    add_index :conferences, :acronym, name: "index_conferences_on_acronym"
    add_index :conflicts, [:event_id, :conflicting_event_id], name: "index_conflicts_on_event_id"
    add_index :conflicts, :person_id, name: "index_conflicts_on_person_id"
    add_index :days, :conference_id, name: "index_days_on_conference"
    add_index :event_attachments, :event_id, name: "index_event_attachments_on_event_id"
    add_index :event_feedbacks, :event_id, name: "index_event_feedbacks_on_event_id"
    add_index :event_people, :event_id, name: "index_event_people_on_event_id"
    add_index :event_people, :person_id, name: "index_event_people_on_person_id"
    add_index :event_ratings, :event_id, name: "index_event_ratings_on_event_id"
    add_index :event_ratings, :person_id, name: "index_event_ratings_on_person_id"
    add_index :events, :conference_id, name: "index_events_on_conference_id"
    add_index :events, :event_type, name: "index_events_on_type"
    add_index :events, :state, name: "index_events_on_state"
    add_index :events, :guid, name: "index_events_on_guid", unique: true
    add_index :im_accounts, :person_id, name: "index_im_accounts_on_person_id"
    add_index :languages, :attachable_id, name: "index_languages_on_attachable_id"
    add_index :links, :linkable_id, name: "index_links_on_linkable_id"
    add_index :people, :email, name: "index_people_on_email"
    add_index :people, :user_id, name: "index_people_on_user_id"
    add_index :phone_numbers, :person_id, name: "index_phone_numbers_on_person_id"
    add_index :rooms, :conference_id, name: "index_rooms_on_conference_id"
    add_index :tickets, :event_id, name: "index_tickets_on_event_id"
    add_index :tracks, :conference_id, name: "index_tracks_on_conference_id"

  end

  def down
    remove_index :users, :confirmation_token
    remove_index :users, :email
    remove_index :users, :reset_password_token
    remove_index :versions, [:item_type, :item_id]
    remove_index :availabilities, :person_id
    remove_index :availabilities, :conference_id
    remove_index :call_for_papers, [:start_date, :end_date]
    remove_index :conferences, :acronym
    remove_index :conflicts, [:event_id, :conflicting_event_id]
    remove_index :conflicts, :person_id
    remove_index :days, :conference_id
    remove_index :event_attachments, :event_id
    remove_index :event_feedbacks, :event_id
    remove_index :event_people, :event_id
    remove_index :event_people, :person_id
    remove_index :event_ratings, :event_id
    remove_index :event_ratings, :person_id
    remove_index :events, :conference_id
    remove_index :events, :event_type
    remove_index :events, :state
    remove_index :events, :guid
    remove_index :im_accounts, :person_id
    remove_index :languages, :attachable_id
    remove_index :links, :linkable_id
    remove_index :people, :email
    remove_index :people, :user_id
    remove_index :phone_numbers, :person_id
    remove_index :rooms, :conference_id
    remove_index :tickets, :event_id
    remove_index :tracks, :conference_id
  end
end
