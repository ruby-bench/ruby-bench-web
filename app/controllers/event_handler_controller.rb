class EventHandlerController < APIController
  def github_event_handler
    GithubEventHandler.new(request, params.to_unsafe_h).handle
    head :ok
  end
end
