class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  validates :username,
            :uniqueness => {
                :case_sensitive => false
            }

  validates_presence_of :username

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :agent_id, :user_type, :username, :code

  attr_accessor :login
  attr_accessible :login

  belongs_to :agent

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value OR lower(code) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end

class User::ParameterSanitizer < Devise::ParameterSanitizer
  def sign_in
    default_params.permit(:username, :email, :user_type)
  end
end
