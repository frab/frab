class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer :call_for_papers_id
      t.timestamps
    end

    Notification.create_translation_table! :accept_subject => :string,
                                           :reject_subject => :string,
                                           :accept_body    => :text,
                                           :reject_body    => :text
  end

  def down
    drop_table :notifications

    Notification.drop_translation_table!
  end
end