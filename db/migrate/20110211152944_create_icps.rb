class CreateIcps < ActiveRecord::Migration
  def self.up
    create_table :icps do |t|
      t.string :name
      t.string :parameters

      t.timestamps
    end
  end

  def self.down
    drop_table :icps
  end
end
