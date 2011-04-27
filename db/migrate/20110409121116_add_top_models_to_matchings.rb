class AddTopModelsToMatchings < ActiveRecord::Migration
  def self.up
    add_column :matchings, :top_models, :integer
  end

  def self.down
    remove_column :matchings, :top_models
  end
end
