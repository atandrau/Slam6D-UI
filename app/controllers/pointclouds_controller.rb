class PointcloudsController < ApplicationController
  
  def index
    @pointclouds = Pointcloud.all
    # slam = Slam6D.new({})
    # render :inline => slam.testOpen
  end

  def new
    @pointcloud = Pointcloud.new
  end
  
  def create
    @pointcloud = Pointcloud.new(params[:pointcloud])
    if @pointcloud.save
      flash[:notice] = "PointCloud added successfully."
      redirect_to @pointcloud
    else
      flash[:notice] = "You have some errors.."
      @pointcloud.move_to_scan_db
      render :new
    end
  end
  
  def show
    @pointcloud = Pointcloud.find(params[:id])
  end
  
  def slam6d_show
    @pointcloud = Pointcloud.find(params[:id])
    sl = Slam6D.new({:pointcloud_id => params[:id]})
    render :inline => sl.runShow
  end
end
