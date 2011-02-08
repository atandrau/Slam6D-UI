class Pointcloud < ActiveRecord::Base
  
  def move_to_scan_db
    extension = ".3d"# if self.format == "3D Warehouse"
    `mkdir #{new_path}#{self.id}`
    new_path = "#{new_path}#{self.id}/scan000#{extension}"
    `cp #{self.path} #{new_path}`
    update_attribute(:path, new_path)
  end
end
