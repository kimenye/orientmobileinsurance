class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, presence: true


  attr_accessible :name, :id_passport, :email, :phone_number, :alternate_phone_number, :lead
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
