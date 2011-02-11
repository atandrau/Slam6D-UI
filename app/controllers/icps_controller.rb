class IcpsController < ApplicationController
  
  def index
    @icps = Icp.all
  end
  
  def new
    @icp = Icp.new
  end
  
  def create
    @icp = Icp.new(params[:icp])
    @icp.save
    redirect_to @icp
  end
  
  def show
    @icp = Icp.find(params[:id])
  end
  
  def run
    @icp = Icp.find(params[:id])
    sl = Slam6D.new({:icp_id => @icp})
    render :inline => sl.runIcp.gsub("\n", "<br>")
  end
  
  def destroy
    @icp = Icp.find(params[:id])
    @icp.destroy
    redirect_to icps_path
  end
  
  def view
    render :inline => "View"
  end
end
