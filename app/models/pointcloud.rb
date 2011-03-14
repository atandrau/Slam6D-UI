class Pointcloud < ActiveRecord::Base
  before_destroy :clean_files
  
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
  
  def name
    id.to_s + " : " + self.label
  end
  
  def reduce_with_frequency(frequency = 2)
    p = Pointcloud.create(:name => "#{self.name}, reduced with frequency #{frequency}",
                          :format => self.format)
    `mkdir #{p.directory}`
    
    in_file = File.new(self.complete_path, "r")
    in_file.gets
    
    out_points = []
    line_number = 0
    while (line = in_file.gets) do
      out_points << line if line_number % frequency == 0
      line_number = line_number + 1
    end
    in_file.close
    
    out_file = File.new(p.complete_path, "w")
    out_file.write(out_points.size.to_s + "\n")
    out_points.each { |line| out_file.write(line) }
    out_file.close
    
    p
  end
  
  def convert_to_uos
    p = Pointcloud.create(:name => "#{self.name}", :format => "uos")
    `mkdir #{p.directory}`
    
    in_file = File.new(self.complete_path, "r")
    out_file = File.new(p.complete_path, "w")
    
    line = in_file.gets # skip first line
    while (line = in_file.gets) do
      points = line.split(" ")
      out_file.write(points[0..2].join(" ") + "\n")
    end
        
    out_file.close
    in_file.close
    
    p
  end
  
  def distance_between(p1, p2)
    0.upto(p1.size - 1).map { |i| (p1[i].to_f - p2[i].to_f) ** 2 }.sum
  end
  
  def get_object(center)
    epsilon = 300
    require 'kd-tree'
    
    in_file = File.new(self.complete_path, "r")
    puts "Reading points"
    
    center = center.split(" ")
    points = []
    closest, closest_dist = [], 1000000
    while(line = in_file.gets) do
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      point = point.map { |p| p.to_f }
      points << point
      
      this_distance = distance_between(center, point)
      closest, closest_dist = points.size - 1, this_distance if this_distance < closest_dist
    end
    
    puts "Found closest point to center"
    
    crt_point = points[closest]
    puts crt_point.to_json
    out_points = []
    points.each do |p|
      a = (0.upto(2).map { |i| (crt_point[i] - p[i]).abs }).max
      out_points << p if a < epsilon
    end
    
    #tree = KDTree.new(points, 3)
    #puts "Created KD Tree"
    
    #out_points = [points[closest]]
    #i = 0
    #while(i < out_points.size)
    #  crt_point = out_points[i]
    #  ranger = crt_point.map{ |p| [p - epsilon, p + epsilon] }
    #  new_points = tree.find(ranger[0], ranger[1], ranger[2])
    #  new_points.each { |p| out_points << p if !out_points.include? p }
    #  
    #  i += 1
    #  puts out_points.size
    #  break
    #end

    puts "writing points = #{out_points.size}"
    p = Pointcloud.create(:label => "#{self.label}, points around #{center.join(" ")}, epsilon #{epsilon}",
                          :format => "uos")
    `mkdir #{p.directory}`
    File.open("#{p.complete_path}", "w") { |f| f.write(out_points.map { |p| p.join(" ")}.join("\n")) }
    p
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
    
    # points.each do |p|
    #   p[0] -= 775.585
    #   p[1] -= 38.7895
    #   p[2] -= 110.747
    # end
    
    p = Pointcloud.create(:label => "#{self.label}, bounded: #{base}, centered",
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
