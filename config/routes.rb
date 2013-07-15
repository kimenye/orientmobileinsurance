Orientmobileinsurance::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config


  #authenticated :user do
  #  root :to => 'home#index'
  #end


  root :to => "home#index"
  devise_for :users
  ActiveAdmin.routes(self)
  resources :users, :mobile

  match 'administration' => 'admin#index', :as => :admin_area

  match 'notification' => 'home#notification', :as => :notifications

end