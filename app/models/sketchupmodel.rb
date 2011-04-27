class Sketchupmodel < ActiveRecord::Base
  has_many :pointclouds, :dependent => :destroy
  accepts_nested_attributes_for :pointclouds
  
  def google_link
    "http://sketchup.google.com/3dwarehouse/details?mid=#{google_id}"
  end
  
  def resample(points_per_area)
    self.pointclouds.last.destroy if self.pointclouds.size >= 3
    
    puts "Model #{id}"
    p = pointclouds[1].resample(points_per_area)
    self.pointclouds << p
    save
  end
  
  def add_scaled_and_centered
    self.pointclouds << self.pointclouds.first.scale_and_center_xyz(500)
    save
  end
  
  def self.schedule_resampling
    Sketchupmodel.all.each { |s| s.delay.resample(0.0005) }
  end
  
  def download
    `wget "http://sketchup.google.com/3dwarehouse/download?mid=#{self.google_id}&rtyp=st&ctyp=other" -O ~/Desktop/models/#{self.google_id}.jpg`
  end
  
  def self.download_all
    Sketchupmodel.all.each do |s|
      s.download
    end
  end
end
