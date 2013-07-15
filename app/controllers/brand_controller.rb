class BrandController < ApplicationController

  def index
    @brands = Brand.all
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def update
    @brand = Brand.find(params[:id])
    if @brand.update_attributes(params[:brand])
      redirect_to brands_path, :notice => "Brand updated."
    else
      redirect_to brands_path, :alert => "Unable to update brand."
    end
  end

  def destroy
    brand = Brand.find(params[:id])
    brand.destroy
    redirect_to brands_path, :notice => "Brand deleted."
  end

  def create
    @brand = Brand.new
    @brand.attributes = params[:brand]
    @brand.save
    redirect_to brands_path, :notice => "Brand created"
  end

end
