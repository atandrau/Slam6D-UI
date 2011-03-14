class RenameNameToLabel < ActiveRecord::Migration
  def self.up
    rename_column :pointclouds, :name, :label
  end

  def self.down
    rename_column :pointclouds, :label, :name
  end
end
