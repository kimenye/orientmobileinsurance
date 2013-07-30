class Users::SessionsController < Devise::SessionsController

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    resource.user_type = params[:user_type]
    respond_with(resource, serialize_options(resource))
  end

end