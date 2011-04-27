class Scan < ActiveRecord::Base
  has_many :pointclouds
  belongs_to :scan_no_ground, :class_name => "Pointcloud"
  
  require 'kd-tree'
  
  def segment
    self.pointclouds.destroy_all
    
    in_file = File.new(self.scan_no_ground.complete_path, "r")
    puts "Reading points"
    
    points = []
    while(line = in_file.gets) do
      next if line.include?("#")
      point = line.split(" ")
      point = point[0..2] if point.size > 3
      point = point.map { |p| p.to_f }
      points << (point + [points.size])
    end
    
    puts "Finished reading points"
    epsilon = 3
    tree = KDTree.new(points, 3)
    
    v = points.map { |p| nil }
    objects = 0
    points.each_with_index do |point, index|
      next unless v[index].nil?
      puts "Found object #{objects}"
      
      objects += 1
      out_points = [point]
      v[index] = objects
      
      i = 0
      while(i < out_points.size)
        crt_point = out_points[i]
        ranger = crt_point.map{ |p| [p - epsilon, p + epsilon] }
        new_points = tree.find(ranger[0], ranger[1], ranger[2])
        
        new_points.each do |p|
          if v[p[3]].nil?
            out_points << p 
            v[p[3]] = objects
          end
        end
        
        i += 1
      end
      
      if out_points.size > 500
        puts "writing points = #{out_points.size}"
        p = Pointcloud.create(:label => "#{self.scan_no_ground.label}, object #{objects}",
                              :format => "uos", :scan_id => self.id, :pointcount => out_points.size)
        `mkdir #{p.directory}`
        File.open("#{p.complete_path}", "w") { |f| f.write(out_points.map { |p| p[0..2].join(" ")}.join("\n")) }
      end
    end
  end
end
