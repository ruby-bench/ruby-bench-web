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

  namespace :admin do
    resources :groups, except: [:show]

    get '' => 'dashboard#dashboard', as: :dashboard
    get 'repos/:repo_name' => 'repos#show', as: :repo
    post 'repos/:repo_name/run_commits' => 'repos#run_commits', as: :run_commits
    post 'repos/:repo_name/run_releases' => 'repos#run_releases', as: :run_releases
  end
end
