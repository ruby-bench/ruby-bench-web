require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  test "User should be able to view a single long running benchmark graph" do
    benchmark_run = benchmark_runs(:array_iterations_run2)

    visit '/ruby/ruby/commits'

    assert page.has_content?(
      I18n.t('repos.show.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show.select_benchmark'))

    within "form" do
      choose(benchmark_run.benchmark_type.category)
    end

    assert page.has_css?("#chart #highcharts-0")
    assert page.has_content?("def abc")

    benchmark_run_category_humanize = benchmark_run.benchmark_type.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{benchmark_run.initiator.repo.organization.name}" \
      "/#{benchmark_run.initiator.repo.name}/commits?result_type=#{benchmark_run.benchmark_type.category}"
    )
  end

  test "User should see long running benchmark categories as sorted" do
    benchmark_run = benchmark_runs(:array_iterations_run2)

    visit '/ruby/ruby/commits'

    within "form" do
      lis = page.all('li input')

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:array_count_run).benchmark_type.category, lis.first.value
      assert_equal benchmark_run.benchmark_type.category, lis.last.value
    end
  end

  test "User should be able to view releases benchmark graphs" do
    benchmark_run = benchmark_runs(:array_iterations_run)

    visit '/ruby/ruby/releases'

    assert page.has_content?(
      I18n.t('repos.show_releases.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show_releases.select_benchmark'))

    within "form" do
      choose(benchmark_run.benchmark_type.category)
    end

    within "#chart .highcharts-container .highcharts-yaxis-title" do
      assert page.has_content?(benchmark_run.benchmark_type.unit.capitalize)
    end

    within "#chart-memory .highcharts-container .highcharts-yaxis-title" do
      assert page.has_content?(
        benchmark_runs(:array_iterations_memory_run).benchmark_type.unit.capitalize
      )
    end

    assert page.has_content?("def abc")

    benchmark_run_category_humanize = benchmark_run.benchmark_type.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} memory Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{benchmark_run.initiator.repo.organization.name}" \
      "/#{benchmark_run.initiator.repo.name}/releases?result_type=#{benchmark_run.benchmark_type.category}"
    )
  end

  test "User should not be able to view releases memory benchmark graph if it
    does not exist".squish do

    benchmark_run = benchmark_runs(:array_count_run)

    visit '/ruby/ruby/releases'

    assert page.has_content?(
      I18n.t('repos.show_releases.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show_releases.select_benchmark'))

    within "form" do
      choose(benchmark_run.benchmark_type.category)
    end

    assert page.has_css?("#chart .highcharts-container")
    assert_not page.has_css?("#chart-memory .highcharts-container")
    assert page.has_content?("def abc")

    benchmark_run_category_humanize = benchmark_run.benchmark_type.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert_not page.has_content?("#{benchmark_run_category_humanize} memory Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{benchmark_run.initiator.repo.organization.name}" \
      "/#{benchmark_run.initiator.repo.name}/releases?result_type=#{benchmark_run.benchmark_type.category}"
    )
  end

  test "User should see releases benchmark categories as sorted" do
    benchmark_run = benchmark_runs(:array_iterations_run)

    visit '/ruby/ruby/releases'

    within "form" do
      lis = page.all('li input')

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:array_count_run).benchmark_type.category, lis.first.value
      assert_equal benchmark_run.benchmark_type.category, lis.last.value
    end
  end

  test "User should not see benchmark categories which have no benchmark runs" do
    benchmark_run = benchmark_runs(:array_shift_run)

    visit '/rails/rails/releases'

    within "form" do
      lis = page.all('li input')
      values = lis.map { |l| l.value }
      assert_not values.include?(benchmark_run.benchmark_type.category)
    end
  end
end
