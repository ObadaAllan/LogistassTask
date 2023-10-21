class AddNameToAuthor < ActiveRecord::Migration[7.0]
  def change
    add_column :authors, :name, :string, unique: true
  end
end
