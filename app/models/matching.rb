class Matching < ActiveRecord::Base
  belongs_to :pointcloud
  belongs_to :best_model, :class_name => :model
  
  def run
    best_error, best_model = -1, 0
    
    rotations = ["0 0 0", "180 0 0", "180 0 180", "180 180 180"]
    results = []
    
    Sketchupmodel.find_all_by_name("Audi A4 resampled").each do |m|
      rotations.each do |r|
        crt_error = error_with_model(m, r)
        puts "#{m.id} - #{r} - #{m.google_id} - #{crt_error}"
        results << [crt_error, m.id, r]
        file = File.new("/Users/alexthero/slam6d.txt", "a")
        file.puts("Model ID: #{m.id}  Rotation: #{r}  Error: #{crt_error}")
        file.close
        best_error, best_model = crt_error, m.id if (crt_error < best_error) || (best_model == 0)
      end
    end
    
    puts "Done!"
    puts best_error
    puts best_model
    
    results
  end
  
  def error_with_model(model, rotation = "0 0 0")
    sl = Slam6D.new({:first_scan_path => pointcloud.complete_path,
                     :second_scan_path => model.pointclouds.last.complete_path,
                     :second_scan_rotation => rotation })
    output = sl.runMatching
    return output.split("F&A\n")[1].split("\n")[0].to_f
  end
end
