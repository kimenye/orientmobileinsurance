class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, :phone_number, presence: true


  attr_accessible :name, :id_passport, :email, :phone_number
  has_many :insured_devices
end
