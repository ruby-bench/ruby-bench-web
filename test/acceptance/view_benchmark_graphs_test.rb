require 'acceptance/test_helper'

class ViewBenchmarkGraphsTest < AcceptanceTest
  test "User should be able to view benchmark graphs" do
    require_js
    benchmark_run = benchmark_runs(:benchmark_run)

    visit root_path

    within first(".table.table-striped") do
      click_link "Rails"
    end

    assert page.has_content?("Rails Benchmarks")
    assert page.has_content?("Please select an option on the left.")

    within "form" do
      choose("result_type_#{benchmark_run.category}")
      click_button 'Submit'
    end

    assert page.has_css?("#chart_0.c3")
  end
end
