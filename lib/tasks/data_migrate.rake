namespace :frab do
  namespace :migrate do

    desc 'regenerate db/schema.rb-mysql from a MySQL database'
    task mysql_schema: :environment do |_t, _args|
      # naive mysql detection to match bin/setup approach
      unless ENV.fetch('DATABASE_URL', '').match('mysql') || File.read('config/database.yml').match(/mysql/)
        abort <<~ERROR

          ERROR: This task requires a MySQL database configuration.

          To use this task:
          1. Set DATABASE_URL environment variable:
             export DATABASE_URL=mysql2://user:password@localhost/frab_development

          OR

          2. Configure config/database.yml for MySQL:
             cp config/database.yml.template-mysql config/database.yml
             # Edit config/database.yml with your MySQL credentials

          Then run:
             rails db:migrate
             rake frab:migrate:mysql_schema

        ERROR
      end

      puts 'Dumping MySQL schema to db/schema.rb-mysql...'
      original_schema_file = Rails.application.config.paths['db'].first + '/schema.rb'
      mysql_schema_file = Rails.application.config.paths['db'].first + '/schema.rb-mysql'
      backup_schema_file = Rails.application.config.paths['db'].first + '/schema.rb.backup'

      # Backup existing schema.rb if it exists
      if File.exist?(original_schema_file)
        FileUtils.cp(original_schema_file, backup_schema_file)
        puts "Backed up existing schema.rb to schema.rb.backup"
      end

      # Dump the current schema
      ActiveRecord::Tasks::DatabaseTasks.dump_schema(ActiveRecord::Base.connection_db_config)

      # Read the generated schema
      schema_content = File.read(original_schema_file)

      # Add FOREIGN_KEY_CHECKS statements
      # Insert after the ActiveRecord::Schema[...].define line
      schema_content.sub!(
        /(ActiveRecord::Schema\[[\d.]+\]\.define\(version: [^\)]+\) do)/,
        "\\1\n  connection.execute(\"SET FOREIGN_KEY_CHECKS = 0\") if connection.adapter_name == 'Mysql2'\n"
      )

      # Insert before the final 'end'
      schema_content.sub!(
        /\nend\s*\z/,
        "\n\n  connection.execute(\"SET FOREIGN_KEY_CHECKS = 1\") if connection.adapter_name == 'Mysql2'\nend"
      )

      # Write the modified schema to the MySQL schema file
      File.write(mysql_schema_file, schema_content)

      # Restore the original schema.rb from backup
      if File.exist?(backup_schema_file)
        FileUtils.mv(backup_schema_file, original_schema_file)
        puts "Restored original schema.rb"
      end

      puts "MySQL schema written to #{mysql_schema_file}"
      puts 'You can now commit this file to version control'
    end

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
