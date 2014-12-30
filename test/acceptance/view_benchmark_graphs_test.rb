require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  test "User should be able to view a single long running benchmark graph" do
    benchmark_run = benchmark_runs(:benchmark_run)

    visit '/ruby/ruby'

    assert page.has_content?(
      I18n.t('repos.show.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show.select_benchmark'))

    within "form" do
      choose(benchmark_run.category)
    end

    assert page.has_css?("#chart #highcharts-0")
    assert page.has_content?("def abc")

    benchmark_run_category_humanize = benchmark_run.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")
  end

  test "User should see long running benchmark categories as sorted" do
    benchmark_run = benchmark_runs(:benchmark_run)

    visit '/ruby/ruby'

    within "form" do
      lis = page.all('li input')

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:benchmark_run2).category, lis.first.value
      assert_equal benchmark_run.category, lis.last.value
    end
  end

  test "User should be able to view a single release benchmark graph" do
    benchmark_run = benchmark_runs(:benchmark_run)

    visit '/ruby/ruby/releases'

    assert page.has_content?(
      I18n.t('repos.show_releases.title', repo_name: benchmark_run.initiator.repo.name.capitalize)
    )

    assert page.has_content?(I18n.t('repos.show_releases.select_benchmark'))

    within "form" do
      choose(benchmark_run.category)
    end

    assert page.has_css?("#chart #highcharts-0")
    assert page.has_content?("def abc")

    benchmark_run_category_humanize = benchmark_run.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")
  end

  test "User should see releases benchmark categories as sorted" do
    benchmark_run = benchmark_runs(:benchmark_run)

    visit '/ruby/ruby/releases'

    within "form" do
      lis = page.all('li input')

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:benchmark_run2).category, lis.first.value
      assert_equal benchmark_run.category, lis.last.value
    end
  end
end
