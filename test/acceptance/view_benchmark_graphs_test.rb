require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    $redis.flushall
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  teardown do
    reset_driver
  end

  test "User should be able to view long running benchmark graphs" do
    benchmark_run = benchmark_runs(:array_iterations_run2)

    visit '/ruby/ruby/commits'

    assert page.has_content?(
      I18n.t('repos.show.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show.select_benchmark'))

    within "form" do
      choose(benchmark_run.benchmark_type.category)
    end

    within ".chart .highcharts-container .highcharts-yaxis-title",
      match: :first do

      assert page.has_content?(benchmark_run.benchmark_type.unit.capitalize)
    end

    assert(
      all(".chart .highcharts-container .highcharts-yaxis-title")
        .last
        .has_content?(
          benchmark_runs(:array_iterations_memory_run2).benchmark_type.unit.capitalize
        )
    )

    assert page.has_content?("def abc")

    within ".highcharts-xaxis-labels", match: :first do
      assert_equal benchmark_run.initiator.created_at.strftime("%Y-%m-%d"),
        find('text').text
    end

    benchmark_run_category_humanize = benchmark_run.benchmark_type.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} memory Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")

    assert_equal(
      URI.parse(page.current_url).request_uri,
      "/#{benchmark_run.initiator.repo.organization.name}" \
      "/#{benchmark_run.initiator.repo.name}/commits?result_type=" \
      "#{benchmark_run.benchmark_type.category}&display_count=#{BenchmarkRun::DEFAULT_PAGINATE_COUNT}"
    )

    benchmark_run = benchmark_runs(:array_count_run)
    benchmark_run_category_humanize = benchmark_run.benchmark_type.category.humanize

    within "form" do
      choose(benchmark_run.benchmark_type.category)
    end

    assert page.has_css?(".chart .highcharts-container")
    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert_not page.has_content?("#{benchmark_run_category_humanize} memory Graph")
  end

  test "User should be able to select number of benchmark runs to display
    for long running benchmark graphs" do

    benchmark_type = benchmark_types(:array_count)

    BenchmarkRun.stub_const(:PAGINATE_COUNT, [1, 3]) do
      BenchmarkRun.stub_const(:DEFAULT_PAGINATE_COUNT, 1) do
        visit "/ruby/ruby/commits?result_type=#{benchmark_type.category}"

        assert assert_selector(".highcharts-markers path", count: 1)

        select 3, from: "benchmark_run_display_count"

        assert assert_selector(".highcharts-markers path", count: 3)
      end
    end
  end

  test "User should see benchmark type categories as sorted" do
    visit '/ruby/ruby/commits'

    within "form" do
      lis = page.all('li input')

      assert_equal(
        lis.map(&:value),
        [
          benchmark_types(:array_count).category,
          benchmark_types(:array_iterations).category,
          benchmark_types(:array_shift).category
        ]
      )
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

    within ".release-chart .highcharts-container .highcharts-yaxis-title",
      match: :first do

      assert page.has_content?(benchmark_run.benchmark_type.unit.capitalize)
    end

    assert(
      all(".release-chart .highcharts-container .highcharts-yaxis-title")
        .last
        .has_content?(
          benchmark_runs(:array_iterations_memory_run).benchmark_type.unit.capitalize
        )
    )

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

    assert page.has_css?(".release-chart .highcharts-container")
    assert_not page.has_css?(".release-chart.memory .highcharts-container")
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

  test "User should see the right message for benchmark types with no
    benchmark runs".squish do

    category = benchmark_types(:array_shift).category
    visit '/ruby/ruby/releases'

    within "form" do
      choose(category)
    end

    assert_not page.has_css?(".release-chart .highcharts-container")
    assert page.has_content?(I18n.t("repos.no_results", category: category))
  end

  test "User should be able to hide benchmark types form" do
    ['/ruby/ruby/releases', '/ruby/ruby/commits'].each do |path|
      visit path
      click_link "benchmark-types-form-hide"

      within "#benchmark-types-form-container" do
        assert page.has_css?('.panel.panel-primary.hide', visible: false)
      end

      click_link  "benchmark-types-form-show"

      within "#benchmark-types-form-container" do
        assert page.has_css?('.panel.panel-primary', visible: true)
      end
    end
  end
end
