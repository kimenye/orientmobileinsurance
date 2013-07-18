class CustomerController < ApplicationController

  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(params[:customer])
      redirect_to customers_path, :notice => "Customer updated."
    else
      redirect_to customers_path, :alert => "Unable to update customer."
    end
  end

  def destroy
    customer = Customer.find(params[:id])
    customer.destroy
    redirect_to customers_path, :notice => "Customer deleted."
  end

  def create
    @customer = Customer.new
    @customer.attributes = params[:customer]
    @customer.save
    redirect_to customers_path, :notice => "Customer created"
  end

end
