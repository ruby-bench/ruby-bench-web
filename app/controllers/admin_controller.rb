class AdminController < ApplicationController
  http_basic_authenticate_with(
    name: 'admin',
    password: Rails.application.secrets.admin_password
  ) unless Rails.env.test?

  layout 'admin'

  before_action :set_repos, :set_admin

  private

  def set_admin
    session['admin'] = true unless session['admin'] || Rails.env.test?
  end

  def set_repos
    @repos = Repo.all
  end
end
