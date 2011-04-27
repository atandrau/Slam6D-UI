class Matching < ActiveRecord::Base
  belongs_to :pointcloud
  belongs_to :best_model, :class_name => :model
  
  belongs_to :scan
  belongs_to :sketchupmodel
  
  serialize :results
  
  def sorted_results
    return [] if results.nil?
    
    r = results.sort.reject { |r| r[0] < 0 }
    models = []
    results = []
    r.map do |p|
      unless models.include?(p[1])
        results << p
        models << p[1]
      end
    end
    results
  end
  
  def rotation_count
    rotations = ["0 0 0", "0 90 0", "0 180 0", "0 270 0"]
    rotations.map { |r| 
      [r, sorted_results.map { |i| i[2] == r ? 1 : 0 }.sum]
    }
  end
  
  def run
    rotations = ["0 0 0", "0 90 0", "0 180 0", "0 270 0"]
    self.update_attribute(:results, [])
    res = []
    
    if self.category == "best_model"
      sketchups = []
      sketchups += Matching.all.map { |m| m.sorted_results[0..top_models - 1].map { |p| Sketchupmodel.find(p[1]) } }.flatten if top_models    
      sketchups += Sketchupmodel.find_all_by_name(model_name) if model_name
    
      return sketchups.each { |m| rotations.each { |r| self.delay.error_with_model(m, r) } }
    else
      pointclouds = self.scan.pointclouds.reject { |r| !r.name.include?("bounded") }
      
      return pointclouds.each { |p| rotations.each { |r| self.delay.error_with_pointcloud(p, r) }}
    end
  end
  
  def error_with_pointcloud(pointcloud, rotation = "0 0 0")
    sl = Slam6D.new({:first_scan_path => pointcloud.complete_path,
                     :second_scan_path => self.sketchupmodel.pointclouds.last.complete_path,
                     :second_scan_rotation => rotation })
    output = sl.runMatching
    crt_error = output.split("F&A\n")[1].split("\n")[0].to_f
    
    puts "#{pointcloud.id} - #{rotation} - #{crt_error}"
    
    res = Matching.find(self.id).results
    res << [crt_error, pointcloud.id, rotation]
    self.update_attribute(:results, res)
  end
  
  def error_with_model(model, rotation = "0 0 0")
    if model.pointclouds.count < 3
      model.resample(0.0001)
      model = Sketchupmodel.find(model.id)
    end
    
    sl = Slam6D.new({:first_scan_path => pointcloud.complete_path,
                     :second_scan_path => model.pointclouds.last.complete_path,
                     :second_scan_rotation => rotation })
    output = sl.runMatching
    crt_error = output.split("F&A\n")[1].split("\n")[0].to_f
    
    puts "#{model.id} - #{rotation} - #{model.google_id} - #{crt_error}"
    
    res = Matching.find(self.id).results
    res << [crt_error, model.id, rotation]
    self.update_attribute(:results, res)    
  end
end
