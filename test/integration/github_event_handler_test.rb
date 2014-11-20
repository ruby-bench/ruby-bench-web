require 'test_helper'

class GithubEventHandlerTest < ActionDispatch::IntegrationTest
  test "#handle for single commits pushed" do
    RemoteServerJob.expects(:perform_later).once
    post_to_handler({ 'head_commit' => { 'id' => '1' } })
  end

  test "#handle for multiple commits pushed" do
    RemoteServerJob.expects(:perform_later).twice
    post_to_handler({ 'commits' => [{ 'id' => '1' }, { 'id' => '2' } ] })
  end

  private

  def post_to_handler(parameters)
    post(
      '/github_event_handler', parameters,
      { "#{GithubEventHandler::HEADER}" => "#{GithubEventHandler::PUSH}" }
    )
  end
end
