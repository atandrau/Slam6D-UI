class SketchupmodelsController < ApplicationController
  before_filter :load_sketchupmodel, :except => [:new, :create, :index]
  
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
    @model = Sketchupmodel.new
  end
  
  def create
    @model = Sktechupmodel.new(params[:sketchupmodel])
    if @model.save
      flash[:notice] = "Sketchup model saved successfully."
      redirect_to sketchupmodels_path
    else
      flash[:notice] = "You have some errors.."
      render :new
    end
  end
  
  def index
    @models = Sketchupmodel.all
  end
  
  protected
  def load_sketchupmodel
    @model = Sketchupmodel.find(params[:id])
  end
end
