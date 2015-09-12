class MoveNotificationsOntoConference < ActiveRecord::Migration
  def change
    add_column :notifications, :conference_id, :integer
    Notification.find_each { |n|
      next unless n.call_for_papers_id
      execute %(UPDATE notifications SET conference_id=(SELECT conference_id FROM call_for_papers AS cfp WHERE cfp.id=#{n.call_for_papers_id}) WHERE id=#{n.id};)
    }
    remove_column :notifications, :call_for_papers_id
  end
end
