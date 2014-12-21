require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    @benchmark_run = benchmark_runs(:benchmark_run)
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  test "User should be able to view a single benchmark graphs" do
    visit root_path

    within first(".table.table-striped") do
      click_link "Rails"
    end

    assert page.has_content?("Rails Benchmarks")
    assert page.has_content?(I18n.t('repos.show.select_benchmark'))

    within "form" do
      check(@benchmark_run.category)
      click_button I18n.t('submit')
    end

    assert page.has_css?("#chart_0.c3")
    assert_not page.has_css?("#chart_1.c3")
    assert page.has_content?("def abc")

    benchmark_run_category_humanize = @benchmark_run.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")
  end

  test "User should be able to view multiple benchmark graphs" do
    benchmark_run2 = benchmark_runs(:benchmark_run2)

    visit "/rails/rails"

    assert page.has_content?("Rails Benchmarks")
    assert page.has_content?(I18n.t('repos.show.select_benchmark'))

    within "form" do
      check("result_type_#{@benchmark_run.category}")
      check("result_type_#{benchmark_run2.category}")
      click_button I18n.t('submit')
    end

    assert page.has_css?("#chart_0.c3")
    assert page.has_css?("#chart_1.c3")

    benchmark_run_category_humanize = @benchmark_run.category.humanize
    benchmark_run2_category_humanize = benchmark_run2.category.humanize

    assert page.has_content?("#{benchmark_run_category_humanize} Graph")
    assert page.has_content?("#{benchmark_run_category_humanize} Script")
    assert page.has_content?("#{benchmark_run2_category_humanize} Graph")
  end

  test "User should see benchmark categories as sorted" do
    visit "/rails/rails"

    within "form" do
      lis = page.all('li input')

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:benchmark_run2).category, lis.first.value
      assert_equal @benchmark_run.category, lis.last.value
    end
  end
end
