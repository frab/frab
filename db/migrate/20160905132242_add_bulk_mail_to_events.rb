class AddBulkMailToEvents < ActiveRecord::Migration
  def change
    add_column :events, :bulk_mail, :string
  end
end
