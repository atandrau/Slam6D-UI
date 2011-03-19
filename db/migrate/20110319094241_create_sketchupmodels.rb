class CreateSketchupmodels < ActiveRecord::Migration
  def self.up
    create_table :sketchupmodels do |t|
      t.string :name
      t.string :google_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sketchupmodels
  end
end
