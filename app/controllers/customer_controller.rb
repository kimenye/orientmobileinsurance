class CustomerController < ApplicationController

  def index
    #@customers = Customer.all
  end

  def login
    customer = Customer.find_by_id_passport(params[:customer_id])
    if !customer.nil?
      session[:customer] = customer
      redirect_to customer_url(customer)
    else
      redirect_to '/customer', :notice => "No customer with ID #{params[:customer_id]} was found"
    end
  end

  def show
    if is_customer_logged_in? params[:id]
      begin
        @customer = Customer.find(params[:id])
      rescue
        redirect_to customer_path
      end
    else
      redirect_to customer_path
    end
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(params[:customer])
      redirect_to customer_path, :notice => "Customer updated."
    else
      redirect_to customer_path, :alert => "Unable to update customer."
    end
  end

  def destroy
    customer = Customer.find(params[:id])
    customer.destroy
    redirect_to customer_path, :notice => "Customer deleted."
  end

  def create
    @customer = Customer.new
    @customer.attributes = params[:customer]
    @customer.save
    redirect_to customer_path, :notice => "Customer created"
  end

end
