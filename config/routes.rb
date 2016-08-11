require 'sidetiq/web'

Rails.application.routes.draw do
  if !Rails.env.test?
    require 'sidekiq/web'

    constraints(lambda { |request| request.session['admin'] }) do
      mount Logster::Web => "/logs"
      mount Sidekiq::Web => "/sidekiq"
    end
  end

  root 'static_pages#landing'

  post 'github_event_handler' => 'event_handler#github_event_handler'
  resources :benchmark_runs, only: [:create]

  get 'hardware' => 'static_pages#hardware'
  get 'contributing' => 'static_pages#contribute', as: :contribute
  get 'sponsors' => 'static_pages#sponsors',  as: :sponsors
  get 'admin' => 'admin#index'
  get 'admin/:organization_name/:repo_name/releases' => 'admin#show_releases', as: :admin_releases_repo
  get 'admin/:organization_name/:repo_name/releases/next' => 'admin#next', as: :admin_submit
  get 'benchmarks' => 'organizations#index'
  get ':organization_name/:repo_name/commits/overview' => 'repos#index', as: :repos
  get ':organization_name/:repo_name/commits' => 'repos#show', as: :repo
  get ':organization_name/:repo_name/releases' => 'repos#show_releases', as: :releases_repo
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
