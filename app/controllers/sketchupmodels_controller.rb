class SketchupmodelsController < ApplicationController
  before_filter :load_sketchupmodel, :except => [:new, :create, :index]
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def update
    if @model.update_attributes(params[:sketchupmodel])
      flash[:notice] = "Sketchup model updated successfully."
      redirect_to sketchupmodels_path
    else
      flash[:notice] = "You have some errors.."
      render :new
    end
  end
  
  def new
    @model = Sketchupmodel.new(:name => "Audi A4")
    @model.pointclouds.build(:format => "uos")
  end
  
  def create
    @model = Sketchupmodel.new(params[:sketchupmodel])
    if @model.save
      @model.pointclouds.first.move_to_scan_db(params[:sketchupmodel][:pointclouds_attributes]["0"])
      @model.update_attribute(:google_id, params[:sketchupmodel][:pointclouds_attributes]["0"]['path'].original_filename.gsub(".3d", "").split("_")[0])
      
      @model.pointclouds.map { |p| p.update_attribute(:label, @model.name) }
      @model.pointclouds << @model.pointclouds.first.scale_and_center_xyz(500)
      @model.save
      
      flash[:notice] = "Sketchup model saved successfully."
      redirect_to sketchupmodels_path
    else
      flash[:notice] = "You have some errors.."
      render :new
    end
  end
  
  def destroy
    @model.destroy
    redirect_to sketchupmodels_path
  end
  
  def index
    @models = Sketchupmodel.all
  end
  
  protected
  def load_sketchupmodel
    @model = Sketchupmodel.find(params[:id])
  end
end
