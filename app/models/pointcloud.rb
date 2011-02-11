class Pointcloud < ActiveRecord::Base
  
  def move_to_scan_db(upload)
    new_path = AppConfig["settings"]["scanDB"]
    extension = ".3d"
    extension = ".txt" if self.format == "riegl_txt"
    
    `mkdir #{new_path}#{self.id}`
    new_path = "#{new_path}#{self.id}/scan000#{extension}"
    
    File.open(new_path, "wb") { |f| f.write(upload['path'].read) }
    
    update_attribute(:path, new_path)
  end
end
