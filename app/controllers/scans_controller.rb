class ScansController < ApplicationController
  before_filter :load_scan, :except => [:index, :new, :create]
  
  def index
    @scans = Scan.all
  end
  
  def segment
    @scan.segment
    redirect_to @scan, :notice => "Scan successfully segmented."
  end
  
  protected
  def load_scan
    @scan = Scan.find(params[:id])
  end
end
