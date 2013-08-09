class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer :call_for_papers_id
      t.timestamps
    end

    if defined? Notification.create_translation_table!
      Notification.create_translation_table! :accept_subject => :string,
                                           :reject_subject => :string,
                                           :accept_body    => :text,
                                           :reject_body    => :text
    end
  end

  def down
    drop_table :notifications

    if defined? Notification.drop_translation_table!
      Notification.drop_translation_table!
    end
  end
end
