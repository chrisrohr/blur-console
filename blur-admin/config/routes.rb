BlurAdmin::Application.routes.draw do
  resource :data, :only => [:show]
  resource :runtime, :controller => 'runtime'
  resource :config, :controller => 'config'
	resource :query, :controller => 'query'
	resource :env, :controller => 'env'

  root :to => "env#show"

  controller "query" do
    match 'query/cancel/:table/:uuid', :to => :cancel, :as => :cancel, :via => :get
    match 'query/current/:table', :to => :current_queries, :as => :current_queries, :via => :get
    match 'query/:table/filters', :to => :filters, :as => :query_filters, :via => :get
  end

  controller "data" do
    match 'data/table/:name', :to => :destroy_table, :via => :delete
    match 'data/table/:name/enable', :to => :enable_table, :via => :put
    match 'data/table/:name/disable', :to => :disable_table, :via => :put
  end

  controller "runtime" do
    match 'runtime/current/:table', :to => :current_queries, :as => :current_queries, :via => :get
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "main#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

