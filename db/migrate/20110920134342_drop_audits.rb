class DropAudits < ActiveRecord::Migration
  def change
    drop_table :audits
  end
end
