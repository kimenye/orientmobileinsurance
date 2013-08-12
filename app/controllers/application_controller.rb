class ApplicationController < ActionController::Base
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

  def dealer_is_logged_in?
    user = current_user
    !user.nil? && user.user_type == "DP"
  end
  
  def claims_is_logged_in?
    user = current_user
    !user.nil? && user.user_type == "CP"
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

end
