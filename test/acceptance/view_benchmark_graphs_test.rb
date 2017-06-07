require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  test 'User should be able to view long running benchmark graphs' do
    repo = create(:repo)
    org = repo.organization
    benchmark_type = create(:benchmark_type, repo: repo)
    commit = create(:commit, repo: repo)
    benchmark_run = create(
      :commit_benchmark_run, benchmark_type: benchmark_type, initiator: commit
    )
    benchmark_result_type = benchmark_run.benchmark_result_type
    memory_benchmark_result_type = create(
      :benchmark_result_type, name: 'Memory', unit: 'Kilobytes'
    )

    create(:commit_benchmark_run,
           initiator: commit, benchmark_type: benchmark_type,
           benchmark_result_type: memory_benchmark_result_type
          )

    visit commits_path(organization_name: org.name, repo_name: repo.name)

    assert page.has_content?(
      I18n.t('repos.commits.title', repo_name: repo.title)
    )

    assert_text :all, I18n.t('repos.commits.select_benchmark')

    within '#benchmark_run_benchmark_type' do
      select(benchmark_type.category)
    end

    within '.chart .highcharts-container .highcharts-yaxis-title',
      match: :first do
      assert page.has_content?(benchmark_result_type.unit)
    end

    assert(
      all('.chart .highcharts-container .highcharts-yaxis-title')
      .last
      .has_content?(memory_benchmark_result_type.unit)
    )

    within '.highcharts-xaxis-labels', match: :first do
      assert_equal commit.created_at.strftime('%Y-%m-%d'),
        find('text').text
    end

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{org.name}" \
      "/#{repo.name}/commits?result_type=" \
      "#{benchmark_type.category}&display_count=#{BenchmarkRun::DEFAULT_PAGINATE_COUNT}"
    )
  end

  test "User should be able to see long running benchmark graph even without
      memory benchmarks".squish do

    benchmark_run = create(:commit_benchmark_run)
    benchmark_type = benchmark_run.benchmark_type
    repo = benchmark_type.repo
    org = repo.organization
    benchmark_run_category_humanize = benchmark_type.category.humanize

    visit commits_path(organization_name: org.name, repo_name: repo.name)

    within '#benchmark_run_benchmark_type' do
      select(benchmark_type.category)
    end

    assert page.has_css?('.chart .highcharts-container')
    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert_not page.has_content?("#{benchmark_run_category_humanize} memory Graph")
  end

  test "User should be able to select number of benchmark runs to display
      for long running benchmark graphs" do

    benchmark_type = create(:benchmark_type)
    repo = benchmark_type.repo
    org = repo.organization
    benchmark_result_type = create(:benchmark_result_type)

    30.times do
      create(
        :commit_benchmark_run, benchmark_type: benchmark_type,
        benchmark_result_type: benchmark_result_type
      )
    end

    visit commits_path(organization_name: org.name, repo_name: repo.name)

    within '#benchmark_run_benchmark_type' do
      select(benchmark_type.category)
    end

    assert assert_selector('.highcharts-markers path', count: 30)

    select 20, from: 'benchmark_run_display_count'

    assert assert_selector('.highcharts-markers path', count: 20)
  end

  test 'User should see benchmark type categories as sorted' do
    repo = create(:repo)
    org = repo.organization
    bm_type = create(:benchmark_type, repo: repo, category: 'd')
    bm_type2 = create(:benchmark_type, repo: repo, category: 'b')
    bm_type3 = create(:benchmark_type, repo: repo, category: 'c')

    visit commits_path(organization_name: org.name, repo_name: repo.name)

    within '#benchmark_run_benchmark_type' do
      list = all('option')
      assert_equal(list.map(&:value), ['', 'b', 'c', 'd'])
    end
  end

  test 'User should be able to view releases benchmark graphs' do
    repo = create(:repo)
    org = repo.organization
    benchmark_type = create(:benchmark_type, repo: repo)
    release = create(:release, repo: repo)
    bm_run = create(:release_benchmark_run, benchmark_type: benchmark_type, initiator: release)
    benchmark_result_type = bm_run.benchmark_result_type
    memory_benchmark_result_type = create(:benchmark_result_type, name: 'Memory', unit: 'rss')

    create(:release_benchmark_run,
           initiator: release, benchmark_type: benchmark_type,
           benchmark_result_type: memory_benchmark_result_type
          )

    visit releases_path(organization_name: org.name, repo_name: repo.name)

    assert page.has_content?(
      I18n.t('repos.releases.title', repo_name: repo.title)
    )

    assert_text :all, I18n.t('repos.commits.select_benchmark')

    within '#benchmark_run_benchmark_type' do
      select(benchmark_type.category)
    end

    within '.release-chart .highcharts-container .highcharts-yaxis-title',
      match: :first do

      assert page.has_content?(benchmark_result_type.unit)
    end

    assert(
      all('.release-chart .highcharts-container .highcharts-yaxis-title')
      .last
      .has_content?(memory_benchmark_result_type.unit)
    )

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{org.name}" \
      "/#{repo.name}/releases?result_type=#{benchmark_type.category}"
    )
  end

  test "User should not be able to view releases memory benchmark graph if it
          does not exist".squish do

    repo = create(:repo)
    org = repo.organization
    benchmark_type = create(:benchmark_type, repo: repo)
    release = create(:release, repo: repo)
    benchmark_run = create(
      :release_benchmark_run,
      benchmark_type: benchmark_type,
      initiator: release
    )

    create(
      :release_benchmark_run,
      benchmark_type: benchmark_type,
      initiator: release,
      created_at: Time.zone.now - 1.day
    )

    visit releases_path(organization_name: org.name, repo_name: repo.name)

    assert page.has_content?(
      I18n.t('repos.releases.title', repo_name: repo.title)
    )

    assert_text :all, I18n.t('repos.commits.select_benchmark')

    within '#benchmark_run_benchmark_type' do
      select(benchmark_type.category)
    end

    assert page.has_css?('.release-chart .highcharts-container')
    assert_not page.has_css?('.release-chart.memory .highcharts-container')
    assert page.has_content?('def abc')

    benchmark_run_category_humanize = benchmark_type.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert_not page.has_content?("#{benchmark_run_category_humanize} memory Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{org.name}" \
      "/#{repo.name}/releases?result_type=#{benchmark_type.category}"
    )
  end

  test "User should see the right message for benchmark types with no
          benchmark runs".squish do

    repo = create(:repo)
    org = repo.organization
    category = create(:benchmark_type, repo: repo).category

    visit releases_path(organization_name: org.name, repo_name: repo.name, result_type: category)

    within '#benchmark_run_benchmark_type' do
      select(category)
    end

    assert_not page.has_css?('.release-chart .highcharts-container')
    assert page.has_content?(I18n.t('repos.no_results', category: category))
  end
end
