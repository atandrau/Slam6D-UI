class AddModelNameAndResultsToMatchings < ActiveRecord::Migration
  def self.up
    add_column :matchings, :model_name, :string
    add_column :matchings, :results, :text
  end

  def self.down
    remove_column :matchings, :results
    remove_column :matchings, :model_name
  end
end
