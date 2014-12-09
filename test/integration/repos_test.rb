require 'test_helper'

class ReposTest < ActionDispatch::IntegrationTest
  test "organization should be a required parameter for show action" do
    get '/rails/rails'
    assert_response 200

    assert_raise(ActionController::RoutingError) do
      get '/tgxworld/rails'
    end
  end
end
