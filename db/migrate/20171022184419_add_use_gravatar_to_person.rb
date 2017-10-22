class AddUseGravatarToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :use_gravatar, :boolean, null: false, default: false
  end
end
