class AddPointcountToPointclouds < ActiveRecord::Migration
  def self.up
    add_column :pointclouds, :pointcount, :integer
  end

  def self.down
    remove_column :pointclouds, :pointcount
  end
end
