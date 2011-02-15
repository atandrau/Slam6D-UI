class AddPosesToIcps < ActiveRecord::Migration
  def self.up
    add_column :icps, :first_scan_position, :string, :default => "0 0 0"
    add_column :icps, :first_scan_rotation, :string, :default => "0 0 0"
    add_column :icps, :second_scan_position, :string, :default => "0 0 0"
    add_column :icps, :second_scan_rotation, :string, :default => "0 0 0"
  end

  def self.down
    remove_column :icps, :second_scan_rotation
    remove_column :icps, :second_scan_position
    remove_column :icps, :first_scan_rotation
    remove_column :icps, :first_scan_position
  end
end
