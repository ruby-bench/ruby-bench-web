require 'sidetiq/web'

Rails.application.routes.draw do
  if !Rails.env.test?
    require 'sidekiq/web'

    constraints(lambda { |request| request.session['admin'] }) do
      mount Logster::Web => '/logs'
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  root 'static_pages#landing'

  post 'github_event_handler' => 'event_handler#github_event_handler'
  resources :benchmark_runs, only: [:create]

  get 'hardware' => 'static_pages#hardware'
  get 'contributing' => 'static_pages#contribute', as: :contribute
  get 'sponsors' => 'static_pages#sponsors',  as: :sponsors
  get 'benchmarks' => 'organizations#index'
  get ':organization_name/:repo_name/commits/overview' => 'repos#index', as: :overview
  get ':organization_name/:repo_name/commits' => 'repos#commits', as: :commits
  get ':organization_name/:repo_name/releases' => 'repos#releases', as: :releases

  get 'admin' => 'admin#home'
  get 'admin/repos/:repo_name' => 'admin#repo', as: :admin_repo
  get 'admin/toggle' => 'admin#toggle_admin'
  post 'admin/repos/:repo_name/run' => 'admin#run', as: :admin_repo_run
end
