class OnlyAdminsAuthorization < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)
    if user.is_admin
      return true
    else
      if subject.to_s == User.to_s || subject.to_s == AdminUser.to_s || action == :edit || ((!subject.is_a?(ActiveAdmin::Comment) && !subject.is_a?(Claim)) && (subject.name == "Simulator" || subject.name == "Reminders"))
        return user.is_admin
      else
        return true
      end
    end
  end
end