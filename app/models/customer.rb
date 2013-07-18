class Customer < ActiveRecord::Base

  validates :name, presence: true
  validates :id_passport, presence: true
  validates :email, presence: true

  attr_accessible :name, :id_passport, :email

end
