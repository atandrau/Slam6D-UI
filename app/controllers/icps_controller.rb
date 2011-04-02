class IcpsController < ApplicationController
  before_filter :load_icp, :except => [:index, :new, :create]
  
  def index
    @icps = Icp.all
  end
  
  def new
    @icp = Icp.new
    @icp.set_parameter_value("--epsICP", "0.0")
  end
  
  def create
    @icp = Icp.new(params[:icp])
    @icp.save
    redirect_to @icp
  end
  
  def update
    @icp.update_attributes(params[:icp])
    redirect_to @icp
  end
  
  def run
    sl = Slam6D.new({:icp_id => @icp})
    @console_output = sl.runIcp
    render :show
  end
  
  def destroy
    @icp.destroy
    redirect_to icps_path
  end
  
  def view
    render :inline => "View"
  end
  
  protected
  def load_icp
    @icp = Icp.find(params[:id])
  end
end
