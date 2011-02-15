class PointcloudsController < ApplicationController
  
  before_filter :load_pointcloud, :except => [:index, :new, :create]
  
  def index
    @pointclouds = Pointcloud.all
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
  
  def scale_and_center
    new_p = @pointcloud.scale_and_center_xyz(params[:bounded].to_f)
    redirect_to new_p
  end
  
  def reduce
    new_p = @pointcloud.reduce_with_frequency(params[:frequency].to_f)
    redirect_to new_p
  end
  
  def slam6d_show
    sl = Slam6D.new({:pointcloud_id => @pointcloud.id})
    render :inline => sl.runShow
  end
  
  def update
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
    @pointcloud.destroy
    redirect_to pointclouds_path
  end
  
  protected
  def load_pointcloud
    @pointcloud = Pointcloud.find(params[:id])
  end

end