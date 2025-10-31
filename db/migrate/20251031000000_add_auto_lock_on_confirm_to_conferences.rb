class AddAutoLockOnConfirmToConferences < ActiveRecord::Migration[7.1]
  def change
    add_column :conferences, :auto_lock_on_confirm, :boolean, default: false
  end
end
