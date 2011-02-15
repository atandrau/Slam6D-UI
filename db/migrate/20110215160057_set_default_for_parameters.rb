class SetDefaultForParameters < ActiveRecord::Migration
  def self.up
    change_column :icps, :parameters, :string, :default => "-a 9 -r 10 -d 500 -i 1000"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted parameters"
  end
end
