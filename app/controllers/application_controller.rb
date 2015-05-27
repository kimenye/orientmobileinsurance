require 'deviceatlas_cloud_client'
class ApplicationController < ActionController::Base
  include DeviceAtlasCloudClient::ControllerHelper

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

      insured_device = claim.policy.insured_device
      insured_device = claim.policy.quote.insured_device if insured_device.nil?
      # return claim.policy.quote.insured_device.customer_id == customer_id
      return insured_device.customer_id == customer_id
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
    logger.debug ">>>> #{properties[:vendor]}"
    logger.debug ">>>> #{properties[:model]}"
    logger.debug ">>>> #{properties[:marketingName]}"
    properties
  end
end
