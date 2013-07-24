class ApplicationController < ActionController::Base
  protect_from_forgery

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

end
