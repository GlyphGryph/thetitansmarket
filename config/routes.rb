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
  get 'character/:id/find_action_target/:action_id' => 'characters#find_action_target', :as => :find_action_target
  get 'character/:id/add_action/:action_id/:target_type/:target_id' => 'characters#add_action_with_target', :as => :add_action_with_target
  get 'character/:id/remove_action/:character_action_id' => 'characters#remove_action', :as => :remove_action
  get 'character/:id/complete_action/:character_action_id' => 'characters#complete_action', :as => :complete_action
  get 'character/:id/ready' => 'characters#ready', :as => :ready
  get 'character/:id/unready' => 'characters#unready', :as => :unready
  get 'character/:id/execute/:world_id' => 'characters#execute', :as => :execute_world
  get 'character/:id/examine/:character_id' => 'characters#examine', :as => :examine_character
  get 'character/:id/show' => 'characters#show', :as => :show_character
  get 'character/:id/history' => 'characters#history', :as => :character_history

  # TODO TODO TODO CHEAT ROUTES - Should be removed before production! TODO TODO TODO #
      get 'character/:id/godmode' => 'characters#godmode', :as => :character_godmode
      get 'character/:id/wish/:type/:target_id(/:quantity)' => 'characters#wish', :as => :character_wish
  ######################################################################################

  get 'character/:id/proposal' => 'proposals#index', :as => :proposals
  get 'character/:id/proposal/:proposal_id/show' => 'proposals#show', :as => :show_proposal
  get 'character/:id/proposal/new/:proposal_type' => 'proposals#new_target', :as => :new_proposal
  get 'character/:id/proposal/new/:proposal_type/with/:target_id' => 'proposals#new_details', :as => :new_proposal_details
  post 'character/:id/proposal/create/:proposal_type/with/:target_id' => 'proposals#create', :as => :create_proposal
  get 'character/:id/proposal/:proposal_id/accept' => 'proposals#accept', :as => :accept_proposal
  get 'character/:id/proposal/:proposal_id/decline' => 'proposals#decline', :as => :decline_proposal
  get 'character/:id/proposal/:proposal_id/cancel' => 'proposals#cancel', :as => :cancel_proposal

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
