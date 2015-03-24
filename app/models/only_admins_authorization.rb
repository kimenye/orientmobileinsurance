class OnlyAdminsAuthorization < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)
    case subject      
    when normalized(Device) || normalized(Agent)
      # Only let the admin create, update and delete devices
      if action == :update || action == :destroy || action == :create #|| action == :upload_file #|| action == :upload_file
        user.is_admin
      else
        true
      end
    when ActiveAdmin::Page
      if action == :read && (subject.name == "Simulator")
        user.is_admin
      else
        true
      end
    else
      true
    end
  end

end