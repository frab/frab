class UpdateDatesForExistingConferences < ActiveRecord::Migration[5.1]
  def change
    execute %(
      UPDATE conferences SET
        start_date=(SELECT min(start_date) FROM days WHERE days.conference_id=conferences.id),
        end_date=(SELECT max(end_date) FROM days WHERE days.conference_id=conferences.id)
    )
  end
end
