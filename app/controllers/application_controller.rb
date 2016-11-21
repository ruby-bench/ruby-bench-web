class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize

  def not_found
    raise ActionController::RoutingError.new('Not found')
  end

  def authorize
    if session['admin']
      Rack::MiniProfiler.authorize_request
    end
  end
end
