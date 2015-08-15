class MoveNotificationsOntoConference < ActiveRecord::Migration
  def change
    add_column :notifications, :conference_id, :integer
    Notification.find_each { |n|
      next unless n.call_for_papers
      n.update(conference_id: n.call_for_papers.conference.id)
    }
    remove_column :notifications, :call_for_papers_id
  end
end
