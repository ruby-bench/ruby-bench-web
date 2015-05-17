require 'acceptance/test_helper'

class ViewBenchmarkGraphCommitModalTest < AcceptanceTest
  setup do
    require_js
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")
  end

  teardown do
    reset_driver
  end

  test "User should be able to view and compare adjacent commits when clicking
    on a point".squish do

    begin
      # Clicking a point on a highchart doesn't work on other drivers. Selenium
      # is really slow so it'll be good to fix this.
      javascript_driver = Capybara.javascript_driver
      default_driver = Capybara.current_driver
      Capybara.javascript_driver = :selenium
      Capybara.current_driver = :selenium

      benchmark_run = benchmark_runs(:array_count_run4)
      benchmark_run2 = benchmark_runs(:array_count_run)
      benchmark_run3 = benchmark_runs(:array_count_run3)

      visit '/ruby/ruby/commits'

      within "form" do
        select(benchmark_run.benchmark_type.category)
      end

      assert page.has_content?(I18n.t("highcharts.subtitle.commit_url"))

      benchmark_run3_line =
        "#{benchmark_run3.initiator.sha1}
        #{benchmark_run3.initiator.message} -
        #{benchmark_run3.result["some_time"]}
        #{benchmark_run3.benchmark_type.unit.capitalize}".squish

      benchmark_run2_line =
        "#{benchmark_run2.initiator.sha1}
        #{benchmark_run2.initiator.message} -
        #{benchmark_run2.result["some_time"]}
        #{benchmark_run2.benchmark_type.unit.capitalize}".squish

      benchmark_run_line =
        "#{benchmark_run.initiator.sha1}
        #{benchmark_run.initiator.message} -
        #{benchmark_run.result["some_time"]}
        #{benchmark_run.benchmark_type.unit.capitalize}".squish

      markers = page.all(".highcharts-markers.highcharts-tracker path")
      markers[0].click
      commit = benchmark_run3.initiator

      within_chart_modal_title do
        assert page.has_content?("Commit: #{commit.sha1}")
        assert page.has_content?("Commit Message: #{commit.message}")
        assert page.has_content?(benchmark_run.environment)
      end

      within_chart_modal_body do
        assert page.has_content?(benchmark_run3_line)
        assert page.has_content?(benchmark_run2_line)
        assert_not page.has_content?(benchmark_run_line)

        assert page.has_selector?(
          "a[href='https://github.com/ruby/ruby/compare/"\
          "#{benchmark_run2.initiator.sha1}...#{benchmark_run3.initiator.sha1}']"
        )
      end

      markers[2].click
      commit = benchmark_run.initiator

      within_chart_modal_title do
        assert page.has_content?("Commit: #{commit.sha1}")
        assert page.has_content?("Commit Message: #{commit.message}")
        assert page.has_content?(benchmark_run.environment)
      end

      within_chart_modal_body do
        assert_not page.has_content?(benchmark_run3_line)
        assert page.has_content?(benchmark_run2_line)
        assert page.has_content?(benchmark_run_line)

        assert page.has_selector?(
          "a[href='https://github.com/ruby/ruby/compare/"\
          "#{benchmark_run.initiator.sha1}...#{benchmark_run2.initiator.sha1}']"
        )
      end

      markers[1].click
      commit = benchmark_run2.initiator

      within_chart_modal_title do
        assert page.has_content?("Commit: #{commit.sha1}")
        assert page.has_content?("Commit Message: #{commit.message}")
        assert page.has_content?(benchmark_run.environment)
      end

      within_chart_modal_body do
        assert page.has_content?(benchmark_run3_line)
        assert page.has_content?(benchmark_run2_line)
        assert page.has_content?(benchmark_run_line)

        assert page.has_selector?(
          "a[href='https://github.com/ruby/ruby/compare/"\
          "#{benchmark_run2.initiator.sha1}...#{benchmark_run3.initiator.sha1}']"
        )

        assert page.has_selector?(
          "a[href='https://github.com/ruby/ruby/compare/"\
          "#{benchmark_run.initiator.sha1}...#{benchmark_run2.initiator.sha1}']"
        )
      end
    ensure
      Capybara.javascript_driver = javascript_driver
      Capybara.current_driver = default_driver
    end
  end

  def within_chart_modal_title
    within "#chart-modal .modal-title" do
      yield
    end
  end

  def within_chart_modal_body
    within "#chart-modal .modal-body" do
      yield
    end
  end
end
