class CreateTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :titles do |t|
      t.string :name, null: false
      t.string :publisher
      t.string :developer
      t.integer :release_year
      t.string :genre
      t.string :platform
      t.text :description

      t.timestamps
    end
    add_index :titles, :name
    add_index :titles, :publisher
    add_index :titles, :release_year
    add_index :titles, :genre
  end
end
