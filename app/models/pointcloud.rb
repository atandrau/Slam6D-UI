class Pointcloud < ActiveRecord::Base
  before_destroy :clean_files
  
  # has_and_belongs_to_many :icps
  
  def move_to_scan_db(upload)
    `mkdir #{self.directory}`
    File.open(self.complete_path, "wb") { |f| f.write(upload['path'].read) }
  end
  
  def extension
    return ".txt" if self.format == "riegl_txt"    
    ".3d"
  end
  
  def directory
    "#{AppConfig["settings"]["scanDB"]}#{self.id}"
  end
  
  def complete_path
    complete = "#{directory}/scan000#{extension}"
  end
  
  def scale_and_center_xyz(base = 1000)
    points = []
    file = File.new(self.complete_path, "r")
    n, sumx, sumy, sumz = 0, 0, 0, 0
    while (line = file.gets)
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      if point.size == 3
        points << point
        n = n + 1
        sumx += point[0].to_f
        sumy += point[1].to_f
        sumz += point[2].to_f
      end
    end
    file.close
    
    centroidX, centroidY, centroidZ = sumx / n, sumy / n, sumz / n
    maximum = 0
    points.each do |p|
      p[0] = p[0].to_f - centroidX.to_f
      p[1] = p[1].to_f - centroidY.to_f
      p[2] = p[2].to_f - centroidZ.to_f
      maximum = [maximum, p[0].abs, p[1].abs, p[2].abs].max
    end
    
    points.each do |p|
      p[0] = p[0] * base / maximum
      p[1] = p[1] * base / maximum
      p[2] = p[2] * base / maximum
    end
    
    p = Pointcloud.create(:name => "#{self.name}, bounded: #{base}, centered",
                         :format => "uos")
    `mkdir #{p.directory}`
    File.open("#{p.complete_path}", "w") { |f| f.write(points.map { |p| p.join(" ")}.join("\n")) }
    p
  end
  
  protected
  
  def clean_files
    `rm -fdr #{self.directory}`
  end
end
