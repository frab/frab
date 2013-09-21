# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131013164530) do

  create_table "availabilities", :force => true do |t|
    t.integer  "person_id"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "day_id"
  end

  add_index "availabilities", ["conference_id"], :name => "index_availabilities_on_conference_id"
  add_index "availabilities", ["person_id"], :name => "index_availabilities_on_person_id"

  create_table "call_for_papers", :force => true do |t|
    t.date     "start_date",    :null => false
    t.date     "end_date",      :null => false
    t.date     "hard_deadline"
    t.text     "welcome_text"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "info_url"
    t.string   "contact_email"
  end

  add_index "call_for_papers", ["start_date", "end_date"], :name => "index_call_for_papers_on_dates"

  create_table "conference_users", :force => true do |t|
    t.string   "role"
    t.integer  "user_id"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "conference_users", ["conference_id"], :name => "index_conference_users_on_conference_id"
  add_index "conference_users", ["user_id"], :name => "index_conference_users_on_user_id"

  create_table "conferences", :force => true do |t|
    t.string   "acronym",                                       :null => false
    t.string   "title",                                         :null => false
    t.string   "timezone",                :default => "Berlin", :null => false
    t.integer  "timeslot_duration",       :default => 15,       :null => false
    t.integer  "default_timeslots",       :default => 4,        :null => false
    t.integer  "max_timeslots",           :default => 20,       :null => false
    t.boolean  "feedback_enabled",        :default => false,    :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "email"
    t.string   "program_export_base_url"
    t.string   "schedule_version"
    t.boolean  "schedule_public",         :default => false,    :null => false
    t.string   "color"
    t.string   "ticket_type"
    t.boolean  "event_state_visible",     :default => true
  end

  add_index "conferences", ["acronym"], :name => "index_conferences_on_acronym"

  create_table "conflicts", :force => true do |t|
    t.integer  "event_id"
    t.integer  "conflicting_event_id"
    t.integer  "person_id"
    t.string   "conflict_type"
    t.string   "severity"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "conflicts", ["event_id", "conflicting_event_id"], :name => "index_conflicts_on_event_id"
  add_index "conflicts", ["person_id"], :name => "index_conflicts_on_person_id"

  create_table "days", :force => true do |t|
    t.integer  "conference_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "days", ["conference_id"], :name => "index_days_on_conference"

  create_table "event_attachments", :force => true do |t|
    t.integer  "event_id",                                  :null => false
    t.string   "title",                                     :null => false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "public",                  :default => true
  end

  add_index "event_attachments", ["event_id"], :name => "index_event_attachments_on_event_id"

  create_table "event_feedbacks", :force => true do |t|
    t.integer  "event_id"
    t.float    "rating"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "event_feedbacks", ["event_id"], :name => "index_event_feedbacks_on_event_id"

  create_table "event_people", :force => true do |t|
    t.integer  "event_id",                                    :null => false
    t.integer  "person_id",                                   :null => false
    t.string   "event_role",         :default => "submitter", :null => false
    t.string   "role_state"
    t.string   "comment"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "confirmation_token"
  end

  add_index "event_people", ["event_id"], :name => "index_event_people_on_event_id"
  add_index "event_people", ["person_id"], :name => "index_event_people_on_person_id"

  create_table "event_ratings", :force => true do |t|
    t.integer  "event_id"
    t.integer  "person_id"
    t.float    "rating"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "event_ratings", ["event_id"], :name => "index_event_ratings_on_event_id"
  add_index "event_ratings", ["person_id"], :name => "index_event_ratings_on_person_id"

  create_table "events", :force => true do |t|
    t.integer  "conference_id",                             :null => false
    t.string   "title",                                     :null => false
    t.string   "subtitle"
    t.string   "event_type",            :default => "talk"
    t.integer  "time_slots"
    t.string   "state",                 :default => "new",  :null => false
    t.string   "language"
    t.datetime "start_time"
    t.text     "abstract"
    t.text     "description"
    t.boolean  "public",                :default => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "track_id"
    t.integer  "room_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.float    "average_rating"
    t.integer  "event_ratings_count",   :default => 0
    t.text     "note"
    t.text     "submission_note"
    t.integer  "speaker_count",         :default => 0
    t.integer  "event_feedbacks_count", :default => 0
    t.float    "average_feedback"
    t.string   "guid"
    t.boolean  "do_not_record",         :default => false
    t.string   "recording_license"
  end

  add_index "events", ["conference_id"], :name => "index_events_on_conference_id"
  add_index "events", ["event_type"], :name => "index_events_on_type"
  add_index "events", ["guid"], :name => "index_events_on_guid", :unique => true
  add_index "events", ["state"], :name => "index_events_on_state"

  create_table "im_accounts", :force => true do |t|
    t.integer  "person_id"
    t.string   "im_type"
    t.string   "im_address"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "im_accounts", ["person_id"], :name => "index_im_accounts_on_person_id"

  create_table "languages", :force => true do |t|
    t.string   "code"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "languages", ["attachable_id"], :name => "index_languages_on_attachable_id"

  create_table "links", :force => true do |t|
    t.string   "title",         :null => false
    t.string   "url",           :null => false
    t.integer  "linkable_id",   :null => false
    t.string   "linkable_type", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "links", ["linkable_id"], :name => "index_links_on_linkable_id"

  create_table "notifications", :force => true do |t|
    t.integer  "call_for_papers_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "locale"
    t.string   "accept_subject"
    t.string   "reject_subject"
    t.text     "accept_body"
    t.text     "reject_body"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name",          :default => ""
    t.string   "last_name",           :default => ""
    t.string   "public_name",                            :null => false
    t.string   "email",                                  :null => false
    t.boolean  "email_public",        :default => true
    t.string   "gender"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "abstract"
    t.text     "description"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "user_id"
    t.text     "note"
    t.boolean  "include_in_mailings", :default => false, :null => false
  end

  add_index "people", ["email"], :name => "index_people_on_email"
  add_index "people", ["user_id"], :name => "index_people_on_user_id"

  create_table "phone_numbers", :force => true do |t|
    t.integer  "person_id"
    t.string   "phone_type"
    t.string   "phone_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "phone_numbers", ["person_id"], :name => "index_phone_numbers_on_person_id"

  create_table "rooms", :force => true do |t|
    t.integer  "conference_id",                   :null => false
    t.string   "name",                            :null => false
    t.integer  "size"
    t.boolean  "public",        :default => true
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "rank"
  end

  add_index "rooms", ["conference_id"], :name => "index_rooms_on_conference_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "ticket_servers", :force => true do |t|
    t.integer  "conference_id", :null => false
    t.string   "url"
    t.string   "user"
    t.string   "password"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "queue"
  end

  create_table "tickets", :force => true do |t|
    t.integer  "event_id",         :null => false
    t.string   "remote_ticket_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "tickets", ["event_id"], :name => "index_tickets_on_event_id"

  create_table "tracks", :force => true do |t|
    t.integer  "conference_id"
    t.string   "name",                                :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "color",         :default => "fefd7f"
  end

  add_index "tracks", ["conference_id"], :name => "index_tracks_on_conference_id"

  create_table "users", :force => true do |t|
    t.string   "email",                :default => "",          :null => false
    t.string   "password_digest",      :default => "",          :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.string   "remember_token"
    t.integer  "sign_in_count",        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "role",                 :default => "submitter"
    t.string   "pentabarf_salt"
    t.string   "pentabarf_password"
    t.integer  "call_for_papers_id"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",       :null => false
    t.integer  "item_id",         :null => false
    t.string   "event",           :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "conference_id"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "videos", :force => true do |t|
    t.integer  "event_id"
    t.string   "url"
    t.string   "mimetype"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "videos", ["event_id"], :name => "index_videos_on_event_id"

end
