class Pointcloud < ActiveRecord::Base
  
  def move_to_scan_db
    new_path = AppConfig["settings"]["scanDB"]
    extension = ".3d"
    extension = ".txt" if self.format == "riegl_txt"
    
    `mkdir #{new_path}#{self.id}`
    new_path = "#{new_path}#{self.id}/scan000#{extension}"
    `cp #{self.path} #{new_path}`
    update_attribute(:path, new_path)
  end
end
