class APIController < ApplicationController
  skip_before_action :verify_authenticity_token

  http_basic_authenticate_with(
    name: Rails.application.secrets.api_name,
    password: Rails.application.secrets.api_password
  )
end
