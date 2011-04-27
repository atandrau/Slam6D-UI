class CreateScans < ActiveRecord::Migration
  def self.up
    create_table :scans do |t|
      t.string :name
      t.integer :scan_no_ground_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scans
  end
end
