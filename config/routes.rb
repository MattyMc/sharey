Rails.application.routes.draw do

  # Friends Controller --------------------------------------------------- 
  post 'friends' => 'friends#create'
  patch 'friends/:id' => 'friends#update'
  get 'friends/:id/destroy' => 'friends#destroy' # Horrible. But I want the destroy button in the same form in friends_table.rb

  # PagesController ------------------------------------------------------  
  root 'pages#home'
  get 'my_friends' => 'pages#my_friends'
  get 'saved_items' => 'pages#saved_items'
  get 'about' => 'pages#about'

  # API - ItemsController ------------------------------------------------
  get 'items/create_or_update'
  get 'items/number_of_unviewed_items'
  get 'items' => 'items#index'
  post 'items' => 'items#create_or_update'
  delete 'items/:id' => 'items#destroy'
  get 'items/:id' => 'items#show'
  get 'username' => 'items#username'
  get 'check_login' => 'items#check_login'

  # Users - SessionsController -------------------------------------------
  get '/sign_out' => 'sessions#destroy', :as => :sign_out
  get "/auth/:provider/callback" => 'sessions#create'

  # ItemsController ------------------------------------------------ 
  get '/retrieve_all_records_from/:model' => "pages#retrieve_all_records_from"


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
