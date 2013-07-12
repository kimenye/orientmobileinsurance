Orientmobileinsurance::Application.routes.draw do
  #authenticated :user do
  #  root :to => 'home#index'
  #end


  root :to => "home#index"
  devise_for :users
  resources :users

  match 'administration' => 'admin#index', :as => :admin_area

end