class AdminController < ApplicationController
  http_basic_authenticate_with(
    name: 'admin',
    password: Rails.application.secrets.admin_password
  )

  def toggle_admin
    session['admin'] = !session['admin']
    redirect_to root_path
  end
end
