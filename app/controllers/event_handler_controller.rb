class EventHandlerController < ApplicationController
  skip_before_action :verify_authenticity_token

  def github_event_handler
    GithubEventHandler.new(request, params).handle
    render nothing: true
  end
end
