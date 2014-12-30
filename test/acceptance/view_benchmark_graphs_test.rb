require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    @benchmark_run = benchmark_runs(:benchmark_run)
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  [
    [
      'long running',
      '/rails/rails',
      [
        I18n.t('repos.show.title', repo_name: 'Rails'),
        I18n.t('repos.show.select_benchmark')
      ]
    ],
    [
      'releases',
      '/rails/rails/releases',
      [
        I18n.t('repos.show_releases.title', repo_name: 'Rails'),
        I18n.t('repos.show.select_benchmark')
      ]
    ]
  ].each do |type, path, page_contents|

    test "User should be able to view a single #{type} benchmark graph" do
      visit path

      page_contents.each do |page_content|
        assert page.has_content?(page_content)
      end

      within "form" do
        choose(@benchmark_run.category)
      end

      assert page.has_css?("#chart_0 #highcharts-0")
      assert_not page.has_css?("#chart_1 #highcharts-1")
      assert page.has_content?("def abc")

      benchmark_run_category_humanize = @benchmark_run.category.humanize

      assert page.has_content?("#{benchmark_run_category_humanize} Graph")
      assert page.has_content?("#{benchmark_run_category_humanize} Script")
    end

    test "User should see #{type} benchmark categories as sorted" do
      visit path

      within "form" do
        lis = page.all('li input')

        assert_equal 2, lis.count
        assert_equal benchmark_runs(:benchmark_run2).category, lis.first.value
        assert_equal @benchmark_run.category, lis.last.value
      end
    end
  end
end
