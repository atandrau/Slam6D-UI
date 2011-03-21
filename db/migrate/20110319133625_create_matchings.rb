class CreateMatchings < ActiveRecord::Migration
  def self.up
    create_table :matchings do |t|
      t.string :name
      t.integer :pointcloud_id
      t.integer :best_model_id

      t.timestamps
    end
  end

  def self.down
    drop_table :matchings
  end
end
