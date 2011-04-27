class AddScanAndModelAndTypeToMatchings < ActiveRecord::Migration
  def self.up
    add_column :matchings, :scan_id, :integer
    add_column :matchings, :sketchupmodel_id, :integer
    add_column :matchings, :category, :string, :default => "best_model"
  end

  def self.down
    remove_column :matchings, :type
    remove_column :matchings, :sketchupmodel_id
    remove_column :matchings, :scan_id
  end
end
