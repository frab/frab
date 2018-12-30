class RemoveVideosTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :videos
  end
end
