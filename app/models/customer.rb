# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  id_passport            :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  phone_number           :string(255)
#  alternate_phone_number :string(255)
#  lead                   :boolean          default(TRUE)
#  customer_type          :string(255)
#  company_name           :string(255)
#  blocked                :boolean          default(FALSE)
#

class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, presence: true
  validates :phone_number, presence: true


  attr_accessible :name, :id_passport, :email, :phone_number, :alternate_phone_number, :lead, :customer_type, :company_name, :blocked
  has_many :insured_devices, :order => 'created_at DESC'
  
  def contact_number
    if alternate_phone_number.blank?
      return phone_number
    else
      return alternate_phone_number
    end
  end

  def first_name
    name.split(" ").first
  end

  def last_name
    names = name.split(" ")
    if names.length > 1
      return names.last
    else
      return nil
    end
  end

  def middle_name
    names = name.split(" ")
    if names.length <= 2
      return nil
    else
      return names.slice(1..names.length-2).join(" ")
    end
  end

  def num_enquiries
    insured_devices.length
  end

  def is_a_lead?
    !has_policy?
  end

  def alternate_number
    number = nil
    if insured_devices.any?
      found = false
      insured_devices.each do |id|
        if !found && id.phone_number != phone_number
          found = true
          number = id.phone_number
        end
      end
    end
    number
  end

  def primary_device
    insured_devices.first
  end

  def is_corporate?
    customer_type == "Corporate"
  end

  def has_policy?
    has_policy = false
    if insured_devices.any?
      insured_devices.each do |id|
        if id.has_policy?
          has_policy = true
        end
      end
    end
    has_policy
  end
end
