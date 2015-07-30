require 'test_helper'

class ReposTest < ActionDispatch::IntegrationTest
  test "organization should a required parameter for show action" do
    organization = create(:organization, name: 'rails')
    create(:repo, name: 'rails', organization: organization)

    get '/rails/rails/commits'
    assert_response 200

    assert_raise(ActionController::RoutingError) do
      get '/tgxworld/rails'
    end
  end
end
