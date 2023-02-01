namespace :frab do
  namespace :migrate do

    desc 'migration 20180213195422 added dates on conferences model'
    task conference_dates: :environment do |_t, _args|
      ActiveRecord::Base.connection.execute %(
        UPDATE conferences SET
        start_date=(SELECT min(start_date) FROM days WHERE days.conference_id=conferences.id),
          end_date=(SELECT max(end_date) FROM days WHERE days.conference_id=conferences.id)
      )
    end

    desc 'migration 20170811224245 adds foreign keys, old mysql does not use bigint for ids'
    task mysql_bigint_fk: :environment do |_t, _args|
      mc = proc do |table, column, type, opts=''|
        ActiveRecord::Base.connection.execute %(ALTER TABLE #{table} MODIFY COLUMN #{column} #{type} #{opts};)
      end

      mc.call :conferences, :id, :bigint, :auto_increment
      mc.call :event_ratings, :id, :bigint, :auto_increment
      mc.call :events, :id, :bigint, :auto_increment
    end

    desc 'migration rails 5.2 database to bigint id for mysql'
    task mysql_bigint_index: :environment do |_t, _args|
      mc = proc do |table, column, type, opts=''|
        ActiveRecord::Base.connection.execute %(ALTER TABLE #{table} MODIFY COLUMN #{column} #{type} #{opts};)
      end

      # model ids
      mc.call :availabilities, :id, :bigint, :auto_increment
      mc.call :average_review_scores, :id, :bigint, :auto_increment
      mc.call :call_for_participations, :id, :bigint, :auto_increment
      mc.call :classifiers, :id, :bigint, :auto_increment
      mc.call :conference_exports, :id, :bigint, :auto_increment
      mc.call :conference_users, :id, :bigint, :auto_increment
      mc.call :conferences, :id, :bigint, :auto_increment
      mc.call :conflicts, :id, :bigint, :auto_increment
      mc.call :days, :id, :bigint, :auto_increment
      mc.call :event_attachments, :id, :bigint, :auto_increment
      mc.call :event_classifiers, :id, :bigint, :auto_increment
      mc.call :event_feedbacks, :id, :bigint, :auto_increment
      mc.call :event_people, :id, :bigint, :auto_increment
      mc.call :event_ratings, :id, :bigint, :auto_increment
      mc.call :event_translations, :id, :bigint, :auto_increment
      mc.call :events, :id, :bigint, :auto_increment
      mc.call :expenses, :id, :bigint, :auto_increment
      mc.call :im_accounts, :id, :bigint, :auto_increment
      mc.call :languages, :id, :bigint, :auto_increment
      mc.call :links, :id, :bigint, :auto_increment
      mc.call :mail_templates, :id, :bigint, :auto_increment
      mc.call :notifications, :id, :bigint, :auto_increment
      mc.call :people, :id, :bigint, :auto_increment
      mc.call :person_translations, :id, :bigint, :auto_increment
      mc.call :phone_numbers, :id, :bigint, :auto_increment
      mc.call :review_metrics, :id, :bigint, :auto_increment
      mc.call :review_scores, :id, :bigint, :auto_increment
      mc.call :rooms, :id, :bigint, :auto_increment
      mc.call :sessions, :id, :bigint, :auto_increment
      mc.call :ticket_servers, :id, :bigint, :auto_increment
      mc.call :tickets, :id, :bigint, :auto_increment
      mc.call :track_translations, :id, :bigint, :auto_increment
      mc.call :tracks, :id, :bigint, :auto_increment
      mc.call :transport_needs, :id, :bigint, :auto_increment
      mc.call :users, :id, :bigint, :auto_increment
      mc.call :versions, :id, :bigint, :auto_increment

      # used in foreign keys
      mc.call :average_review_scores, :event_id, :bigint
      mc.call :average_review_scores, :review_metric_id, :bigint
      mc.call :classifiers, :conference_id, :bigint
      mc.call :event_classifiers, :classifier_id, :bigint
      mc.call :event_classifiers, :event_id, :bigint
      mc.call :event_translations, :event_id, :bigint
      mc.call :person_translations, :person_id, :bigint
      mc.call :review_metrics, :conference_id, :bigint
      mc.call :review_scores, :review_metric_id, :bigint
      mc.call :review_scores, :event_rating_id, :bigint
      mc.call :track_translations, :track_id, :bigint

      # other references
      mc.call :availabilities, :person_id, :bigint
      mc.call :availabilities, :conference_id, :bigint
      mc.call :availabilities, :day_id, :bigint
      mc.call :call_for_participations, :conference_id, :bigint
      mc.call :conference_exports, :conference_id, :bigint
      mc.call :conference_users, :user_id, :bigint
      mc.call :conference_users, :conference_id, :bigint
      mc.call :conferences, :parent_id, :bigint
      mc.call :conflicts, :event_id, :bigint
      mc.call :conflicts, :conflicting_event_id, :bigint
      mc.call :conflicts, :person_id, :bigint
      mc.call :days, :conference_id, :bigint
      mc.call :event_attachments, :event_id, :bigint
      mc.call :event_feedbacks, :event_id, :bigint
      mc.call :event_people, :event_id, :bigint
      mc.call :event_people, :person_id, :bigint
      mc.call :event_ratings, :event_id, :bigint
      mc.call :event_ratings, :person_id, :bigint
      mc.call :events, :conference_id, :bigint
      mc.call :events, :track_id, :bigint
      mc.call :events, :room_id, :bigint
      mc.call :expenses, :person_id, :bigint
      mc.call :expenses, :conference_id, :bigint
      mc.call :im_accounts, :person_id, :bigint
      mc.call :languages, :attachable_id, :bigint
      mc.call :links, :linkable_id, :bigint
      mc.call :mail_templates, :conference_id, :bigint
      mc.call :notifications, :conference_id, :bigint
      mc.call :people, :user_id, :bigint
      mc.call :phone_numbers, :person_id, :bigint
      mc.call :rooms, :conference_id, :bigint
      mc.call :ticket_servers, :conference_id, :bigint
      mc.call :tickets, :object_id, :bigint
      mc.call :tracks, :conference_id, :bigint
      mc.call :transport_needs, :person_id, :bigint
      mc.call :transport_needs, :conference_id, :bigint
      mc.call :versions, :item_id, :bigint
      mc.call :versions, :conference_id, :bigint
      mc.call :versions, :associated_id, :bigint
    end

  end
end
