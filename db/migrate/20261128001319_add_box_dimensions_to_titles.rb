class AddBoxDimensionsToTitles < ActiveRecord::Migration[8.1]
  def change
    add_column :titles, :box_width_mm, :integer
    add_column :titles, :box_height_mm, :integer
    add_column :titles, :box_depth_mm, :integer
  end
end
