Orientmobileinsurance::Application.routes.draw do
  resources :claims


  resources :insured_devices


  devise_for :admin_users, ActiveAdmin::Devise.config


  #authenticated :user do
  #  root :to => 'home#index'
  #end


  root :to => "home#index"

  match 'enquiry/secure' => 'enquiry#secure'

  match 'enquiry/status_check' => 'enquiry#status_check'

  devise_for :users
  ActiveAdmin.routes(self)

  resources :users, :mobile, :messages, :enquiry
  resources :enquiries, :status, :customer

  match 'administration' => 'admin#index', :as => :admin_area
  match 'customer-login' => 'customer#login', :as => :customer_login

  match 'new_claim' => 'enquiries#new_claim', :as => :make_new_claim
  match 'new_status' => 'enquiries#enquire_status', :as => :enquire_status

  match 'notification' => 'messages#create', :as => :notifications

end