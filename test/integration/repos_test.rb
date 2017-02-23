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

  test "JSON generation works when there is one chart" do
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

    res = JSON.parse(response.body, symbolize_names: true)

    assert_includes res.keys, :benchmark_name
    assert_includes res.keys, :charts
    assert_includes res.keys, :versions
    assert_equal res[:charts].length, 1
    assert_includes res[:charts][0].keys, :measurement
    assert_includes res[:charts][0].keys, :unit
    assert_equal res[:charts][0][:datasets].length, 1
  end

  test "JSON generation works when there are two charts" do
    benchmark_type = create(:benchmark_type)
    benchmark_result_type = create(:benchmark_result_type)
    benchmark_result_type2 = create(:benchmark_result_type)

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

    benchmark_run3 = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type2,
      benchmark_type: benchmark_type,
      initiator: commit
    )
    benchmark_run3 = create(:commit_benchmark_run,
      benchmark_result_type: benchmark_result_type2,
      benchmark_type: benchmark_type,
      initiator: later_commit
    )

    get "/#{org.name}/#{repo.name}/commits.json?result_type=#{benchmark_type.category}",
      params: { display_count: 2, result_type: benchmark_result_type }

    res = JSON.parse(response.body, symbolize_names: true)

    assert_includes res.keys, :benchmark_name
    assert_includes res.keys, :charts
    assert_includes res.keys, :versions
    assert_equal res[:charts].length, 2
    assert_includes res[:charts][0].keys, :measurement
    assert_includes res[:charts][0].keys, :unit
    assert_equal res[:charts][0][:datasets].length, 1
  end
end
