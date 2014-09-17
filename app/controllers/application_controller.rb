# require 'deviceatlasapi'
require 'deviceatlas_cloud_client'
class ApplicationController < ActionController::Base
  # include DeviceAtlasApi::ControllerHelpers
  include DeviceAtlasCloudClient::ControllerHelper

  # protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def is_customer_logged_in? id=nil
    session_customer = session[:customer]
    in_session = !session_customer.nil?

    if !id.nil?
      return in_session && session_customer.id == id.to_i
    else
      return in_session
    end
  end

  def customer_can_see_claim? claim_id
    logged_in = is_customer_logged_in?
    claim = Claim.find_by_id claim_id
    if logged_in && !claim.nil?
      customer_id = session[:customer].id
      return claim.policy.quote.insured_device.customer_id == customer_id
    end
    return false
  end

  def configure_permitted_parameters
    if resource_class == User
      User::ParameterSanitizer.new(User, :user, params)
    end
  end

  protected

  def get_device_data
    properties = {}
    if ENV['DEBUG_DEVICE_ATLAS'] == 'false'
      client = get_deviceatlas_cloud_client_instance
      client.settings.licence_key = ENV['DEVICE_ATLAS_LICENCE_KEY']
      device_data = client.get_device_data()
      properties = device_data[DeviceAtlasCloudClient::KEY_PROPERTIES]
    else
      properties[:vendor] = ENV["DEBUG_DEVICE_ATLAS_VENDOR"]
      properties[:model] = ENV["DEBUG_DEVICE_ATLAS_MODEL"]
      properties[:marketingName] = ENV["DEBUG_DEVICE_ATLAS_MARKETING_NAME"]
    end
    logger.info ">>>> #{properties[:vendor]}"
    logger.info ">>>> #{properties[:model]}"
    logger.info ">>>> #{properties[:marketingName]}"
    properties
  end

  # def add_client_properties! device_data
  #   device_data = {} if device_data.nil?
  #   device_data["device.devicePixelRatio"] = request.cookies["device.devicePixelRatio"]
  #   device_data["device.availHeight"] = request.cookies["device.availHeight"]
  # end

  # def get_model_name device_data
  #   device_data = {} if device_data.nil?
  #   model = device_data["model"]
  #   if device_data["osIOs"]
  #     numeric_version =  device_data["osVersion"].gsub("_", ".").to_f
  #     avail_height = device_data["device.availHeight"].to_i
  #     device_pixel_ratio = device_data["device.devicePixelRatio"].to_i
  #     if device_data["isMobilePhone"]
  #       if numeric_version >= 5
  #         if device_pixel_ratio >= 2
  #           if avail_height == 548
  #             model = "iPhone 5"
  #           else
  #             model = "iPhone 4S"
  #             #how to tell between 4 & 4s?
  #           end
  #         elsif device_pixel_ratio == 1
  #           model = "iPhone 3GS"
  #         end
  #       else
  #         model = "iPhone 3G"
  #       end
  #     end
  #   end
  #   model
  # end

  # helper_method :get_model_name
end
