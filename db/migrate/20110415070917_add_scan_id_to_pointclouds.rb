class AddScanIdToPointclouds < ActiveRecord::Migration
  def self.up
    add_column :pointclouds, :scan_id, :integer
  end

  def self.down
    remove_column :pointclouds, :scan_id
  end
end
