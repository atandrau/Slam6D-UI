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
      flash[:notice] = "Point cloud added successfully."
      @pointcloud.move_to_scan_db(params[:pointcloud])
      redirect_to @pointcloud
    else
      flash[:notice] = "You have some errors.."
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
  
  def edit
    @pointcloud = Pointcloud.find(params[:id])
  end
  
  def update
    @pointcloud = Pointcloud.find(params[:id])
    if @pointcloud.update_attributes(params[:pointcloud])
      flash[:notice] = "Point cloud updated successfully."
      @pointcloud.move_to_scan_db
      redirect_to @pointcloud
    else
      flash[:notice] = "You have some errors.."
      render :edit
    end
  end
  
  def destroy
    @pointcloud = Pointcloud.find(params[:id])
    @pointcloud.destroy
    redirect_to pointclouds_path
  end
end
