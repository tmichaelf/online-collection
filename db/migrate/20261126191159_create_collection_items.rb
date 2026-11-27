class CreateCollectionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :title, null: false, foreign_key: true
      t.string :condition, null: false, default: "complete"
      t.text :notes
      t.date :acquired_on

      t.timestamps
    end
    add_index :collection_items, [ :user_id, :title_id ], unique: true
  end
end
