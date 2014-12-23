class EventHandlerController < APIController
  def github_event_handler
    GithubEventHandler.new(request, params).handle
    render nothing: true
  end
end
