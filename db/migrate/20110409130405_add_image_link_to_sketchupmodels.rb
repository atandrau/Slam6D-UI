class AddImageLinkToSketchupmodels < ActiveRecord::Migration
  def self.up
    add_column :sketchupmodels, :image_link, :string
  end

  def self.down
    remove_column :sketchupmodels, :image_link
  end
end
