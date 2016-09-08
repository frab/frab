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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160905132242) do

  create_table "availabilities", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "conference_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "day_id"
  end

  add_index "availabilities", ["conference_id"], name: "index_availabilities_on_conference_id"
  add_index "availabilities", ["person_id"], name: "index_availabilities_on_person_id"

  create_table "call_for_participations", force: :cascade do |t|
    t.date     "start_date",                null: false
    t.date     "end_date",                  null: false
    t.date     "hard_deadline"
    t.text     "welcome_text"
    t.integer  "conference_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "info_url",      limit: 255
    t.string   "contact_email", limit: 255
  end

  add_index "call_for_participations", ["start_date", "end_date"], name: "index_call_for_papers_on_dates"

  create_table "conference_exports", force: :cascade do |t|
    t.string   "locale",               limit: 255
    t.integer  "conference_id"
    t.string   "tarball_file_name",    limit: 255
    t.string   "tarball_content_type", limit: 255
    t.integer  "tarball_file_size"
    t.datetime "tarball_updated_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "conference_exports", ["conference_id"], name: "index_conference_exports_on_conference_id"

  create_table "conference_users", force: :cascade do |t|
    t.string   "role",          limit: 255
    t.integer  "user_id"
    t.integer  "conference_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "conference_users", ["conference_id"], name: "index_conference_users_on_conference_id"
  add_index "conference_users", ["user_id"], name: "index_conference_users_on_user_id"

  create_table "conferences", force: :cascade do |t|
    t.string   "acronym",                   limit: 255,                            null: false
    t.string   "title",                     limit: 255,                            null: false
    t.string   "timezone",                  limit: 255,     default: "Berlin",     null: false
    t.integer  "timeslot_duration",                         default: 15,           null: false
    t.integer  "default_timeslots",                         default: 3,            null: false
    t.integer  "max_timeslots",                             default: 20,           null: false
    t.boolean  "feedback_enabled",                          default: false,        null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "email",                     limit: 255
    t.string   "program_export_base_url",   limit: 255
    t.string   "schedule_version",          limit: 255
    t.boolean  "schedule_public",                           default: false,        null: false
    t.string   "color",                     limit: 255
    t.string   "ticket_type",               limit: 255,     default: "integrated"
    t.boolean  "event_state_visible",                       default: true
    t.text     "schedule_custom_css",       limit: 2097152
    t.text     "schedule_html_intro",       limit: 2097152
    t.string   "default_recording_license", limit: 255
    t.boolean  "expenses_enabled",                          default: false,        null: false
    t.boolean  "transport_needs_enabled",                   default: false,        null: false
  end

  add_index "conferences", ["acronym"], name: "index_conferences_on_acronym"

  create_table "conflicts", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "conflicting_event_id"
    t.integer  "person_id"
    t.string   "conflict_type",        limit: 255
    t.string   "severity",             limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "conflicts", ["event_id", "conflicting_event_id"], name: "index_conflicts_on_event_id"
  add_index "conflicts", ["person_id"], name: "index_conflicts_on_person_id"

  create_table "days", force: :cascade do |t|
    t.integer  "conference_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "days", ["conference_id"], name: "index_days_on_conference"

  create_table "event_attachments", force: :cascade do |t|
    t.integer  "event_id",                                           null: false
    t.string   "title",                   limit: 255,                null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "public",                              default: true
  end

  add_index "event_attachments", ["event_id"], name: "index_event_attachments_on_event_id"

  create_table "event_feedbacks", force: :cascade do |t|
    t.integer  "event_id"
    t.float    "rating"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_feedbacks", ["event_id"], name: "index_event_feedbacks_on_event_id"

  create_table "event_people", force: :cascade do |t|
    t.integer  "event_id",                                             null: false
    t.integer  "person_id",                                            null: false
    t.string   "event_role",         limit: 255, default: "submitter", null: false
    t.string   "role_state",         limit: 255
    t.string   "comment",            limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "confirmation_token", limit: 255
  end

  add_index "event_people", ["event_id"], name: "index_event_people_on_event_id"
  add_index "event_people", ["person_id"], name: "index_event_people_on_person_id"

  create_table "event_ratings", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "person_id"
    t.float    "rating"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_ratings", ["event_id"], name: "index_event_ratings_on_event_id"
  add_index "event_ratings", ["person_id"], name: "index_event_ratings_on_person_id"

  create_table "events", force: :cascade do |t|
    t.integer  "conference_id",                                      null: false
    t.string   "title",                 limit: 255,                  null: false
    t.string   "subtitle",              limit: 255
    t.string   "event_type",            limit: 255, default: "talk"
    t.integer  "time_slots"
    t.string   "state",                 limit: 255, default: "new",  null: false
    t.string   "language",              limit: 255
    t.datetime "start_time"
    t.text     "abstract"
    t.text     "description"
    t.boolean  "public",                            default: true
    t.string   "logo_file_name",        limit: 255
    t.string   "logo_content_type",     limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "track_id"
    t.integer  "room_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.float    "average_rating"
    t.integer  "event_ratings_count",               default: 0
    t.text     "note"
    t.text     "submission_note"
    t.integer  "speaker_count",                     default: 0
    t.integer  "event_feedbacks_count",             default: 0
    t.float    "average_feedback"
    t.string   "guid",                  limit: 255
    t.boolean  "do_not_record",                     default: false
    t.string   "recording_license",     limit: 255
    t.text     "tech_rider"
    t.string   "bulk_mail"
  end

  add_index "events", ["conference_id"], name: "index_events_on_conference_id"
  add_index "events", ["event_type"], name: "index_events_on_type"
  add_index "events", ["guid"], name: "index_events_on_guid", unique: true
  add_index "events", ["state"], name: "index_events_on_state"

  create_table "expenses", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.decimal  "value"
    t.boolean  "reimbursed"
    t.integer  "person_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "conference_id"
  end

  add_index "expenses", ["person_id"], name: "index_expenses_on_person_id"

  create_table "im_accounts", force: :cascade do |t|
    t.integer  "person_id"
    t.string   "im_type",    limit: 255
    t.string   "im_address", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "im_accounts", ["person_id"], name: "index_im_accounts_on_person_id"

  create_table "languages", force: :cascade do |t|
    t.string   "code",            limit: 255
    t.integer  "attachable_id"
    t.string   "attachable_type", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "languages", ["attachable_id"], name: "index_languages_on_attachable_id"

  create_table "links", force: :cascade do |t|
    t.string   "title",         limit: 255, null: false
    t.string   "url",           limit: 255, null: false
    t.integer  "linkable_id",               null: false
    t.string   "linkable_type", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "links", ["linkable_id"], name: "index_links_on_linkable_id"

  create_table "mail_templates", force: :cascade do |t|
    t.integer  "conference_id"
    t.string   "name",          limit: 255
    t.string   "subject",       limit: 255
    t.text     "content"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "mail_templates", ["conference_id"], name: "index_mail_templates_on_conference_id"

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "locale",         limit: 255
    t.string   "accept_subject", limit: 255
    t.string   "reject_subject", limit: 255
    t.text     "accept_body"
    t.text     "reject_body"
    t.integer  "conference_id"
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name",          limit: 255, default: ""
    t.string   "last_name",           limit: 255, default: ""
    t.string   "public_name",         limit: 255,                 null: false
    t.string   "email",               limit: 255,                 null: false
    t.boolean  "email_public",                    default: true
    t.string   "gender",              limit: 255
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "abstract"
    t.text     "description"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "user_id"
    t.text     "note"
    t.boolean  "include_in_mailings",             default: false, null: false
  end

  add_index "people", ["email"], name: "index_people_on_email"
  add_index "people", ["user_id"], name: "index_people_on_user_id"

  create_table "phone_numbers", force: :cascade do |t|
    t.integer  "person_id"
    t.string   "phone_type",   limit: 255
    t.string   "phone_number", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "phone_numbers", ["person_id"], name: "index_phone_numbers_on_person_id"

  create_table "rooms", force: :cascade do |t|
    t.integer  "conference_id",             null: false
    t.string   "name",          limit: 255, null: false
    t.integer  "size"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "rank"
  end

  add_index "rooms", ["conference_id"], name: "index_rooms_on_conference_id"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "ticket_servers", force: :cascade do |t|
    t.integer  "conference_id",             null: false
    t.string   "url",           limit: 255
    t.string   "user",          limit: 255
    t.string   "password",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "queue",         limit: 255
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "object_id",                    null: false
    t.string   "remote_ticket_id", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "object_type"
  end

  add_index "tickets", ["object_id"], name: "index_tickets_on_object_id"

  create_table "tracks", force: :cascade do |t|
    t.integer  "conference_id"
    t.string   "name",          limit: 255,                    null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "color",         limit: 255, default: "fefd7f"
  end

  add_index "tracks", ["conference_id"], name: "index_tracks_on_conference_id"

  create_table "transport_needs", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "conference_id"
    t.datetime "at"
    t.string   "transport_type"
    t.integer  "seats"
    t.boolean  "booked"
    t.text     "note"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "transport_needs", ["conference_id"], name: "index_transport_needs_on_conference_id"
  add_index "transport_needs", ["person_id"], name: "index_transport_needs_on_person_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                limit: 255, default: "",          null: false
    t.string   "password_digest",      limit: 255, default: "",          null: false
    t.string   "reset_password_token", limit: 255
    t.datetime "remember_created_at"
    t.string   "remember_token",       limit: 255
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",   limit: 255
    t.string   "last_sign_in_ip",      limit: 255
    t.string   "confirmation_token",   limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "role",                 limit: 255, default: "submitter"
    t.string   "pentabarf_salt",       limit: 255
    t.string   "pentabarf_password",   limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",       limit: 255,     null: false
    t.integer  "item_id",                         null: false
    t.string   "event",           limit: 255,     null: false
    t.string   "whodunnit",       limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.integer  "conference_id"
    t.integer  "associated_id"
    t.string   "associated_type", limit: 255
    t.text     "object_changes",  limit: 4194304
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "videos", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "url",        limit: 255
    t.string   "mimetype",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "videos", ["event_id"], name: "index_videos_on_event_id"

end
