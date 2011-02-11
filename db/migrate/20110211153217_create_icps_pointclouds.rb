class CreateIcpsPointclouds < ActiveRecord::Migration
  def self.up
    create_table :icps_pointclouds, :id => false do |t|
      t.integer :icp_id
      t.integer :pointcloud_id
    end
  end

  def self.down
    drop_table :icps_pointclouds
  end
end
