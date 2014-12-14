require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  setup do
    require_js
    @benchmark_run = benchmark_runs(:benchmark_run)
  end

  test "User should be able to view a single benchmark graphs" do
    visit root_path

    within first(".table.table-striped") do
      click_link "Rails"
    end

    assert page.has_content?("Rails Benchmarks")
    assert page.has_content?("Please select an option on the left.")

    within "form" do
      choose("result_type_#{@benchmark_run.category}")
      click_button 'Submit'
    end

    assert page.has_css?("#chart_0.c3")
  end


  test "User should be able to clear all benchmark graphs" do
    visit "/rails/rails?result_type=#{@benchmark_run.category}"

    assert page.has_content?("Rails Benchmarks")
    assert page.has_css?("#chart_0.c3")

    within "form" do
      choose("result_type_none")
      click_button 'Submit'
    end

    assert page.has_content?("Please select an option on the left.")
  end

  test "User should be able to view all benchmark graphs" do
    visit "/rails/rails"

    assert page.has_content?("Rails Benchmarks")
    assert page.has_content?("Please select an option on the left.")

    within "form" do
      choose("result_type_all")
      click_button 'Submit'
    end

    assert page.has_css?("#chart_0.c3")
    assert page.has_css?("#chart_1.c3")
  end

  test "User should see benchmark categories as sorted" do
    visit "/rails/rails"

    within "form" do
      lis = page.all('li input')[2..-1]

      assert_equal 2, lis.count
      assert_equal benchmark_runs(:benchmark_run2).category, lis.first.value
      assert_equal @benchmark_run.category, lis.last.value
    end
  end
end
