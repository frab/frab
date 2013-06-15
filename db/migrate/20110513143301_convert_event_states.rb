class ConvertEventStates < ActiveRecord::Migration
  def self.up
    # Undefined method? Event.disable_auditing
    Event.all.each do |event|
      event.state = event.progress unless event.state == "rejected"
      event.state = "confirmed" if event.state == "reconfirmed"
      event.state = "review" if event.state == "rejection-candidate"
      event.save(validate: false)
    end
    remove_column :events, :progress
    change_column :events, :state, :string, default: "new", null: false
  end

  def self.down
    add_column :events, :progress, :string, default: "new", null: false
    Event.reset_column_information
    # Undefined method? Event.disable_auditing
    Event.all.each do |event|
      event.progress = event.state
      case event.progress
      when "new", "review", "withdrawn"
        event.state = "undecided"
      when "unconfirmed", "confirmed", "canceled"
        event.state = "accepted"
      when "rejected"
        event.progress = "done"
      end
      event.save(validate: false)
    end
    change_column :events, :state, :string, default: "undecided", null: false
  end
end
