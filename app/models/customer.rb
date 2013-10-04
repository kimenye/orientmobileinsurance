class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, presence: true


  attr_accessible :name, :id_passport, :email, :phone_number, :alternate_phone_number
  has_many :insured_devices
  
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
end
