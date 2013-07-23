Orientmobileinsurance::Application.routes.draw do
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
  resources :enquiries, :status

  match 'administration' => 'admin#index', :as => :admin_area

  match 'notification' => 'messages#create', :as => :notifications

end