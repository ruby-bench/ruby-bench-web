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
  get 'admin' => 'admin#toggle_admin'
  get 'benchmarks' => 'organizations#index'
  get ':organization_name/:repo_name/commits/overview' => 'repos#index', as: :repos
  get ':organization_name/:repo_name/commits' => 'repos#show', as: :repo
  get ':organization_name/:repo_name/releases' => 'repos#show_releases', as: :releases_repo
end
