class DeviceController < ApplicationController

  def index
    @devices = Device.all
  end

  def show
    @device = Device.find(params[:id])
  end

  def update
    @device = Device.find(params[:id])
    if @device.update_attributes(params[:device])
      redirect_to devices_path, :notice => "Device updated."
    else
      redirect_to devices_path, :alert => "Unable to update device."
    end
  end

  def destroy
    device = Device.find(params[:id])
    device.destroy
    redirect_to devices_path, :notice => "Device deleted."
  end

  def create
    @device = Device.new
    @device.attributes = params[:device]
    @device.save
    redirect_to devices_path, :notice => "Device created"
  end

end
