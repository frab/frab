class AddVideoUrlToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :video_url, :string, limit: 255
  end
end
