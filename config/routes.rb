Rails.application.routes.draw do
  devise_for :users
  resources :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'frontpage#index'
  
  get 'world/:id/join' => 'worlds#join', :as => :join_world
  get 'world/new' => 'worlds#new', :as => :new_world
  get 'character/:id' => 'characters#overview', :as => :character_overview
  get 'character/:id/add_action/:action_id' => 'characters#add_action', :as => :add_action
  get 'character/:id/remove_action/:character_action_id' => 'characters#remove_action', :as => :remove_action
  get 'character/:id/ready' => 'characters#ready', :as => :ready
  get 'character/:id/unready' => 'characters#unready', :as => :unready
  get 'character/:id/execute/:world_id' => 'characters#execute', :as => :execute_world
  get 'character/:id/examine/:character_id' => 'characters#examine', :as => :examine_character
  get 'character/:id/show' => 'characters#show', :as => :show_character

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
