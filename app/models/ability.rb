class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :read, ActiveAdmin::Page, :name => "Dashboard"
    can :read, Claim
    can :read, Policy
    can :read, InsuredDevice
    can :read, Quote
    can :read, Payment
    can :read, Device
    can :read, Agent
    can :read, Brand
    can :read, Customer
    can :read, Message
    can :read, Enquiry
    can :read, Sms


    can :manage, ActiveAdmin::Comment
    if user.is_admin
        can :manage, ActiveAdmin::Page, name: "Simulator"
        can :manage, Device
        can :manage, Agent
        can :create, Customer
        can :update, Customer
        can :update, InsuredDevice
        can :manage, User
        can :manage, AdminUser
    end
  end
end
