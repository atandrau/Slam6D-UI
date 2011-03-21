class Sketchupmodel < ActiveRecord::Base
  has_many :pointclouds, :dependent => :destroy
  accepts_nested_attributes_for :pointclouds
  
  def google_link
    "http://sketchup.google.com/3dwarehouse/details?mid=#{google_id}"
  end
end
