class CreateCallForPapers < ActiveRecord::Migration
  def self.up
    create_table :call_for_papers do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :hard_deadline
      t.text :welcome_text
      t.integer :conference_id

      t.timestamps
    end
  end

  def self.down
    drop_table :call_for_papers
  end
end
