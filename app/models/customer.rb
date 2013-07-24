class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, presence: true


  attr_accessible :name, :id_passport, :email, :phone_number, :alternate_phone_number
  has_many :insured_devices
end
