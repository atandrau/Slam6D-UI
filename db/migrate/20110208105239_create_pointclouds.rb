class CreatePointclouds < ActiveRecord::Migration
  def self.up
    create_table :pointclouds do |t|
      t.string :name
      t.string :path
      t.string :source
      t.string :format
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :pointclouds
  end
end
