class AddTransfMatrixToPointclouds < ActiveRecord::Migration
  def self.up
    add_column :pointclouds, :transf_matrix, :string
  end

  def self.down
    remove_column :pointclouds, :transf_matrix
  end
end
