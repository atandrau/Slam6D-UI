class Pointcloud < ActiveRecord::Base
  belongs_to :sketchupmodel
  belongs_to :scan
  
  before_destroy :clean_files
  
  scope :independent, :conditions => { :sketchupmodel_id => nil }
  
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
    "#{id} : #{self.label}"
  end
  
  def inverse_transf_matrix
    return nil unless self.transf_matrix
    a = self.transf_matrix.gsub("[", "").gsub("]", "").split(", ").map { |b| b.to_f }
    a[0] = 1 / a[0]
    a[5] = 1 / a[5]
    a[10] = 1 / a[10]
    a[12] = - a[12] * a[0]
    a[13] = - a[13] * a[0]
    a[14] = - a[14] * a[0]
    
    a.to_s
  end
  
  def inverse_times(other)
    a = self.inverse_transf_matrix.gsub("[", "").gsub("]", "").split(", ").map { |b| b.to_f }
    b = other.split(" ")[0..15].map { |a| a.to_f }
  
    # Compute a * b
    a1 = [[a[0], a[4], a[8], a[12]],
          [a[1], a[5], a[9], a[13]],
          [a[2], a[6], a[10], a[14]],
          [a[3], a[7], a[11], a[15]]]
    b1 = [[b[0], b[4], b[8], b[12]],
          [b[1], b[5], b[9], b[13]],
          [b[2], b[6], b[10], b[14]],
          [b[3], b[7], b[11], b[15]]]

    c = 0.upto(3).map { |i| 0.upto(3).map { |j| 0 }}
    0.upto(3) {|i|
      0.upto(3) { |j|
        0.upto(3) { |k|
          c[i][j] += a1[i][k] * b1[k][j]
          }
        }
      }
    
    (0.upto(3).map { |i| 0.upto(3).map { |j| c[j][i] }}.flatten << 1).to_s.gsub("[", "").gsub("]", "").gsub(",", "")
  end
  
  def multiply_inverse(file)
    out = []
    
    in_file = File.new(file, "r")
    while (line = in_file.gets) do
      out << inverse_times(line)
    end
    in_file.close
    
    out_file = File.new(file, "w")
    out.each { |line| out_file.write(line + "\n") }
    out_file.close
  end
  
  def triangleArea(a, b, c)
    (0.5 * (a[0] * b[1] * c[2] + b[0] * c[1] * a[2] + c[0] * a[1] * b[2] - c[0] * b[1] * a[2] - b[0] * a[1] * c[2] - a[0] * c[1] * b[2])).abs
  end
  
  def points_js
    in_file = File.new(self.complete_path, "r")
    points = []
    while(line = in_file.gets) do
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      point = point.map { |p| p.to_i }
      points << point
    end
    in_file.close
    
    puts points.size
    points.sort_by {rand}[0..5000].to_json
  end
  
  def resample(points_per_area)
    points = []
    
    puts "Reading points"
    in_file = File.new(self.complete_path, "r")
    while(line = in_file.gets) do
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      point = point.map { |p| p.to_f }
      points << point
    end
    in_file.close
    puts "Finished reading #{points.size} points"
    puts "Starting to resample"
    
    final_points = []
    index = 0
    total_slices = points.size / 3
    if points.size < 300000
      points.each_slice(3) do |p|
        index += 1
        final_points << p[0]
        final_points << p[1]
        final_points << p[2]
      
        area = triangleArea(p[0], p[1], p[2])
        0.upto((area * points_per_area).to_i) do |i|
          a = rand()
          b = rand()
          c = 1 - a - b
          while c < 0 do
            a = rand()
            b = rand()
          
            c = 1 - a - b
          end
          r = [a, b, c].shuffle
          a, b, c = r[0], r[1], r[2]
        
          new_point = [p[0][0] * a + p[1][0] * b + p[2][0] * c,
                       p[0][1] * a + p[1][1] * b + p[2][1] * c,
                       p[0][2] * a + p[1][2] * b + p[2][2] * c]
          final_points << new_point
        end
      
        if final_points.size > 600000
          return resample(points_per_area / 10)
        end
      end
    else
      final_points = points
    end
    # final_points.uniq!
    
    puts "writing points = #{final_points.size}"
    p = Pointcloud.create(:label => "#{self.label}, resampled #{points_per_area} points per area unit",
                          :format => "uos")
    `mkdir #{p.directory}`
    File.open("#{p.complete_path}", "w") { |f| f.write(final_points.map { |p| p[0..2].join(" ")}.join("\n")) }
    p
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
      points << (point + [points.size])
      
      this_distance = distance_between(center, point)
      closest, closest_dist = points.size - 1, this_distance if this_distance < closest_dist
    end
    
    puts "Found closest point to center"
    
    epsilon = 5
    tree = KDTree.new(points, 3)
    puts "Created KD Tree"
  
    v = points.map { |p| false }
    out_points = [points[closest]]
    v[closest] = true
    i = 0
    while(i < out_points.size)
      crt_point = out_points[i]
      ranger = crt_point.map{ |p| [p - epsilon, p + epsilon] }
      new_points = tree.find(ranger[0], ranger[1], ranger[2])
      
      new_points.each do |p|
        unless v[p[3]]
          out_points << p 
          v[p[3]] = true
        end
      end
    
      i += 1
      puts out_points.size
    end

    puts "writing points = #{out_points.size}"
    p = Pointcloud.create(:label => "#{self.label}, points around #{center.join(" ")}, epsilon #{epsilon}",
                          :format => "uos")
    `mkdir #{p.directory}`
    File.open("#{p.complete_path}", "w") { |f| f.write(out_points.map { |p| p[0..2].join(" ")}.join("\n")) }
    p
  end
  
  def switch_y_z
    file = File.new(self.complete_path, "r")
    points = []
    while(line = file.gets)
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      point[1], point[2] = point[2], point[1]
      point[1] = -1 * point[1].to_f
      points << point
    end
    
    File.open("#{self.complete_path}", "w") { |f| f.write(points.map { |p| p.join(" ")}.join("\n")) }
  end
  
  def scale_and_center_xyz(base = 500)
    transf = 1.upto(16).map { |i| 0 }
    
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
    
    transf[12] = -centroidX.to_f * base / maximum
    transf[13] = -centroidY.to_f * base / maximum
    transf[14] = -centroidZ.to_f * base / maximum
    transf[15] = 1
    
    points.each do |p|
      p[0] = p[0] * base / maximum
      p[1] = p[1] * base / maximum
      p[2] = p[2] * base / maximum
    end
    
    transf[0] = base / maximum
    transf[5] = base / maximum
    transf[10] = base / maximum
    
    p = Pointcloud.create(:label => "#{self.label}, bounded: #{base}, centered",
                          :format => "uos", :transf_matrix => transf.to_s, :scan_id => self.scan_id,
                          :pointcount => self.pointcount)
    `mkdir #{p.directory}`
    File.open("#{p.complete_path}", "w") { |f| f.write(points.map { |p| p.join(" ")}.join("\n")) }
    p
  end
  
  protected
  def clean_files
    `rm -fdr #{self.directory}`
  end
end
