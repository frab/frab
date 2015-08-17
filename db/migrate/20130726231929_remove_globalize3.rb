class RemoveGlobalize3 < ActiveRecord::Migration
  def up
    # remove notifications
    # rename notification_translations -> notifications
    # replace notification_id with call_for_papers_id

    change_table :notifications do |t|
      t.string :locale
      t.string :accept_subject
      t.string :reject_subject
      t.text :accept_body
      t.text :reject_body

      #t.drop :notification_id
      #t.references :call_for_papers, index: true
    end

    unless ActiveRecord::Base.connection.table_exists? 'notification_translations'
      return
    end

    # migrate data
    migrated = {}
    sql = "select notification_id,locale,accept_subject,reject_subject,accept_body,reject_body from notification_translations;"
    records = ActiveRecord::Base.connection.execute(sql)
    records.each { |e|
      n = Notification.find(e[0].to_i)
      migrated[n.id] = 1

      new = Notification.new
      new.call_for_papers_id = n.call_for_papers_id
      new.locale = e[1]
      new.accept_subject = e[2]
      new.reject_subject = e[3]
      new.accept_body = e[4]
      new.reject_body = e[5]

      new.save!
    }

    migrated.keys.each { |id|
      n = Notification.find(id)
      n.destroy
    }
    drop_table :notification_translations
  end

  def down
    # not possible
  end
end
