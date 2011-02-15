class AddScanIdsToIcps < ActiveRecord::Migration
  def self.up
    add_column :icps, :first_scan_id, :integer
    add_column :icps, :second_scan_id, :integer
  end

  def self.down
    remove_column :icps, :second_scan_id
    remove_column :icps, :first_scan_id
  end
end
