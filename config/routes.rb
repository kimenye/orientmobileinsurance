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

  match 'enquiries/:hashed_phone_number/:hashed_timestamp' => 'enquiries#show'

  devise_for :users, :controllers => { :sessions => "users/sessions" }
  ActiveAdmin.routes(self)

  resources :users, :mobile, :messages, :enquiry
  resources :enquiries, :status, :customer, :claims

  match 'administration' => 'admin#index', :as => :admin_area
  match 'customer-login' => 'customer#login', :as => :customer_login

  match 'new_claim' => 'enquiries#new_claim', :as => :make_new_claim
  match 'new_status' => 'enquiries#enquire_status', :as => :enquire_status

  match 'enquiries/send_sms' => 'enquiries#send_sms', :as => :send_enquiry_sms

  match 'notification' => 'messages#create', :as => :notifications
  match 'notification2' => 'messages#create2', :as => :notifications
  match 'receipts' => 'messages#receipts', :as => :receipts
  match 'claim_search' => 'claims#search', :as => :claim_search
  match 'claim_search_by_no' => 'claims#search_by_claim_no', :as => :claim_search_by_no
  match 'payment_notification' => 'enquiry#payment_notification', :as => :payment_notification

end