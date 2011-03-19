class Sketchupmodel < ActiveRecord::Base
  has_many :pointclouds, :dependent => :destroy
  accepts_nested_attributes_for :pointclouds
end
