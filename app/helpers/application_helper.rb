module ApplicationHelper
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
end
