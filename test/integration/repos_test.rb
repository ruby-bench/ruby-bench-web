require 'test_helper'

class ReposTest < ActionDispatch::IntegrationTest

  testcases = JSON.parse(file_fixture("json_generator_tests.json").read, symbolize_names: true)

  test "organization should a required parameter for show action" do
    organization = create(:organization, name: 'rails')
    create(:repo, name: 'rails', organization: organization)

    get '/rails/rails/commits'
    assert_response 200

    assert_raise(ActionController::RoutingError) do
      get '/tgxworld/rails'
    end
  end

  test "query JSON endpoint should return JSON object" do
    benchmark_type = create(:benchmark_type)
    benchmark_result_type = create(:benchmark_result_type)

    repo = benchmark_type.repo
    org = repo.organization

    commit = create(:commit, repo: repo)
    later_commit = create(:commit, repo: repo, created_at: Time.zone.now + 1.day)

    benchmark_run = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: benchmark_type,
      initiator: commit
    )

    benchmark_run2 = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type,
      benchmark_type: benchmark_type,
      initiator: later_commit
    )

    get "/#{org.name}/#{repo.name}/commits.json?result_type=#{benchmark_type.category}",
      params: { display_count: 2, result_type: benchmark_result_type }

    chart = JSON.parse(response.body, symbolize_names: true)[0]
    # must have these 4 keys
    assert_includes chart.keys, :benchmark_name
    assert_includes chart.keys, :datapoints
    assert_includes chart.keys, :measurement
    assert_includes chart.keys, :unit
  end
end
