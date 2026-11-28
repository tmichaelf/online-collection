class AddSearchableToTitles < ActiveRecord::Migration[8.1]
  def change
    add_column :titles, :searchable, :virtual, type: :tsvector, stored: true, as: <<~SQL.squish
      setweight(to_tsvector('simple', coalesce(name, '')), 'A') ||
      setweight(to_tsvector('simple', coalesce(publisher, '') || ' ' || coalesce(developer, '')), 'B') ||
      setweight(to_tsvector('simple', coalesce(genre, '') || ' ' || coalesce(platform, '')), 'C') ||
      setweight(to_tsvector('simple', coalesce(description, '')), 'D')
    SQL
    add_index :titles, :searchable, using: :gin
    add_index :titles, :platform
  end
end
