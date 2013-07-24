class Status
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity
  extend  ActiveModel::Naming

  attr_accessor :customer_id, :insured_device_id, :enquiry_type, :action, :contact_tel_no
  validates_presence_of :customer_id

  def persisted?
    return false
  end

  def update_attributes(values, options = {})
    sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
      send("#{k}=", v)
    end
  end

end