class AddSketchupmodelIdToPointclouds < ActiveRecord::Migration
  def self.up
    add_column :pointclouds, :sketchupmodel_id, :integer
  end

  def self.down
    remove_column :pointclouds, :sketchupmodel_id
  end
end
