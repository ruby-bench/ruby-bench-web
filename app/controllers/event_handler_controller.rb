class EventHandlerController < APIController
  def github_event_handler
    GithubEventHandler.new(request, params).handle
    head :ok
  end
end
