module ApplicationHelper
  include DeviceAtlasApi::ControllerHelpers

  def dealer_is_logged_in?
    user = current_user
    !user.nil? && user.user_type == "DP"
  end

  def service_centre_is_logged_in?
    user = current_user
    !user.nil? && user.user_type == "SC"
  end

  def claims_is_logged_in?
    user = current_user
    !user.nil? && user.user_type == "CP"
  end

  def is_asha?
    if session[:is_asha].nil?
      device = get_device_data
      model = device["model"]
      if !model.nil?
        match = model.downcase.match /asha/
        if !match.nil?
          session[:is_asha] = true
        else
          session[:is_asha] = false
        end
      else
        session[:is_asha] = false
      end
    end
    puts "Is ASHA #{session[:is_asha]}"
    session[:is_asha]
  end

end
