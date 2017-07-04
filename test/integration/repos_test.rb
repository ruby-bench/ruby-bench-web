require 'test_helper'

class ReposTest < ActionDispatch::IntegrationTest
  test 'organization should a required parameter for show action' do
    organization = create(:organization, name: 'rails')
    create(:repo, name: 'rails', organization: organization)

    get '/rails/rails/commits'
    assert_response 200

    assert_raise(ActionController::RoutingError) do
      get '/tgxworld/rails'
    end
  end

  test 'JSON generation works when there is one chart' do
    benchmark = create(:benchmark)
    result_type = create(:result_type)

    repo = benchmark.repo
    org = repo.organization

    commit = create(:commit, repo: repo)
    later_commit = create(:commit, repo: repo, created_at: 1.day.from_now)

    benchmark_run = create(
      :commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: commit
    )

    benchmark_run2 = create(
      :commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: later_commit
    )

    get "/#{org.name}/#{repo.name}/commits.json?result_type=#{benchmark.label}",
      params: { display_count: 2 }

    res = JSON.parse(response.body, symbolize_names: true)

    assert_includes res.keys, :benchmark_name
    assert_includes res.keys, :charts
    assert_includes res.keys, :versions
    assert_equal res[:charts].length, 1
    assert_includes res[:charts][0].keys, :measurement
    assert_includes res[:charts][0].keys, :unit
    assert_equal res[:charts][0][:datasets].length, 1
  end

  test 'JSON generation works when there are two charts' do
    benchmark = create(:benchmark)
    result_type = create(:result_type)
    result_type2 = create(:result_type)

    repo = benchmark.repo
    org = repo.organization

    commit = create(:commit, repo: repo)
    later_commit = create(:commit, repo: repo, created_at: 1.day.from_now)

    benchmark_run = create(
      :commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: commit
    )
    benchmark_run2 = create(
      :commit_benchmark_run,
      result_type: result_type,
      benchmark: benchmark,
      initiator: later_commit
    )

    benchmark_run3 = create(
      :commit_benchmark_run,
      result_type: result_type2,
      benchmark: benchmark,
      initiator: commit
    )
    benchmark_run3 = create(
      :commit_benchmark_run,
      result_type: result_type2,
      benchmark: benchmark,
      initiator: later_commit
    )

    get "/#{org.name}/#{repo.name}/commits.json?result_type=#{benchmark.label}",
      params: { display_count: 2 }

    res = JSON.parse(response.body, symbolize_names: true)

    assert_includes res.keys, :benchmark_name
    assert_includes res.keys, :charts
    assert_includes res.keys, :versions
    assert_equal res[:charts].length, 2
    assert_includes res[:charts][0].keys, :measurement
    assert_includes res[:charts][0].keys, :unit
    assert_equal res[:charts][0][:datasets].length, 1
  end

  test '#JSON generation works when there are no charts' do
    benchmark = create(:benchmark)
    result_type = create(:result_type)
    repo = benchmark.repo
    org = repo.organization

    get "/#{org.name}/#{repo.name}/commits.json?result_type=#{benchmark.label}",
      params: { display_count: 2 }

    res = JSON.parse(response.body, symbolize_names: true)

    assert_empty res[:charts]
    assert_empty res[:versions]
    assert_nil res[:benchmark_name]
  end
end
