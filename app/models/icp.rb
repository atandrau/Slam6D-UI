class Icp < ActiveRecord::Base
  # has_and_belongs_to_many :pointclouds
  belongs_to :first_scan, :class_name => "Pointcloud"
  belongs_to :second_scan, :class_name => "Pointcloud"
  
  def pointclouds
    pc = []
    pc << self.first_scan if self.first_scan
    pc << self.second_scan if self.second_scan
    pc
  end
end
