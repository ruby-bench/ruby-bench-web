require 'test_helper'

class UserScriptsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "anon users are prompted to login" do
    get '/user-scripts'
    assert_response :success
    assert_includes response.body, I18n.t("user_scripts.index.login_required")
  end

  test "untrusted logged-in users can't see form to submit scripts" do
    sign_in
    get '/user-scripts'
    assert_response :forbidden
    assert_includes response.body, I18n.t("user_scripts.index.not_enough_permissions")
  end

  test "trusted users can see form" do
    sign_in trusted: true
    get '/user-scripts'
    assert_response :success
    assert_includes response.body, I18n.t("user_scripts.index.script_url")
    assert_includes response.body, I18n.t("user_scripts.index.script_name")
  end

  test "untrusted users can't POST to #create" do
    sign_in
    post '/user-scripts.json', params: { name: "some_benchmark", url: "http://script.com", sha: "asdsadsad" }
    assert_response :forbidden
    assert_equal BenchmarkType.where(category: "some_benchmark", from_user: true).count, 0
  end

  test "trusted users can POST to #create" do
    sign_in trusted: true
    assert_enqueued_with(job: RunUserBench) do
      VCR.use_cassette('github ruby 6ffef8d459') do
        post '/user-scripts.json', params: { name: "some_benchmark", url: "http://script.com", sha: "6ffef8d459" }
      end
    end
    assert_response :success
    assert_equal response.body, "Success! Results will be published <a href=\"/ruby/ruby/commits?result_type=some_benchmark\">here</a>."
    assert_equal BenchmarkType.where(category: "some_benchmark", from_user: true).count, 1
  end
end
