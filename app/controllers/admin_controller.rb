class AdminController < ApplicationController
  http_basic_authenticate_with(
    name: 'admin',
    password: Rails.application.secrets.admin_password
  ) unless Rails.env.test?

  layout 'admin'

  before_action :set_repos, :set_admin
  before_action :set_repo, only: [:repo, :run]

  def set_admin
    session['admin'] = true unless session['admin'] || Rails.env.test?
  end

  def home
  end

  def repo
  end

  def run
    ManualRunner.new(@repo).run_last(
      params[:count].to_i,
      pattern: params[:pattern] == 'all' ? '' : params[:pattern]
    )

    redirect_to admin_repo_path(@repo.name), notice: "#{@repo.name.capitalize} suite is running for last #{params[:count].to_i} commits."
  end

  private

  def set_repos
    @repos = Repo.all
  end

  def set_repo
    @repo = Repo.find_by(name: params[:repo_name])
  end
end
