namespace :frab do
  namespace :migrate do

    desc 'migration 20180213195422 added dates on conferences model'
    task conference_dates: :environment do |_t, _args|
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      ActiveRecord::Base.connection.execute %(
        UPDATE conferences SET
        start_date=(SELECT min(start_date) FROM days WHERE days.conference_id=conferences.id),
          end_date=(SELECT max(end_date) FROM days WHERE days.conference_id=conferences.id)
      )
    end

    desc 'migration 20170811224245 adds foreign keys, old mysql does not use bigint for ids'
    task mysql_bigint_fk: :environment do |_t, _args|
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      ActiveRecord::Base.connection.execute %(
          ALTER TABLE conferences MODIFY COLUMN id bigint auto_increment;
      )
      ActiveRecord::Base.connection.execute %(
          ALTER TABLE event_ratings MODIFY COLUMN id bigint auto_increment;
      )
      ActiveRecord::Base.connection.execute %(
          ALTER TABLE events MODIFY COLUMN id bigint auto_increment;
      )
    end

  end
end
