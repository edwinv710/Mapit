class FixLayersColumn < ActiveRecord::Migration
  def up
  	rename_column :layers, :is_repeat, :is_y_repeat
  end

  def down
  	rename_column :layers, :is_y_repeat, :is_repeat
  end
end
