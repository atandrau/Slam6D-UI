class MatchingsController < ApplicationController
  before_filter :load_matching, :except => [:index, :new, :create]
  
  def new
    @matching = Matching.new
  end
  
  def create
    @matching = Matching.new(params[:matching])
    if @matching.save
      flash[:notice] = "Matching saved"
      redirect_to @matching
    else
      flash[:notice] = "You have some errors.."
      render :new
    end
  end
  
  def index
    @matchings = Matching.all
  end
  
  def run
    @matching.delay.run
    redirect_to @matching, :notice => "Running matching scheduled"
  end

  protected
  def load_matching
    @matching = Matching.find(params[:id])
  end
end
