class OnlyAdminsAuthorization < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)
    if user.is_admin
      return true
    else
      case subject.name
        when User.to_s, AdminUser.to_s, "Simulator"
          return user.is_admin
      end
      return true
    end
  end
end