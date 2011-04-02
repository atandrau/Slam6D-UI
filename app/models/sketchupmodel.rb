class Sketchupmodel < ActiveRecord::Base
  has_many :pointclouds, :dependent => :destroy
  accepts_nested_attributes_for :pointclouds
  
  def google_link
    "http://sketchup.google.com/3dwarehouse/details?mid=#{google_id}"
  end
  
  def resample(points_per_area)
    puts "Model #{id}"
    p = pointclouds[1].resample(points_per_area)
    self.pointclouds << p
    save
  end
  
  def add_scaled_and_centered
    self.pointclouds << self.pointclouds.first.scale_and_center_xyz(500)
    save
  end
end
