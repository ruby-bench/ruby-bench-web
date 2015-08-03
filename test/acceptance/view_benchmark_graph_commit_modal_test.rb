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

      time_now = Time.zone.now
      benchmark_type = create(:benchmark_type)
      benchmark_result_type = create(:benchmark_result_type)
      @repo = benchmark_type.repo
      @org = @repo.organization

      benchmark_run = create(
        :commit_benchmark_run,
        created_at: time_now - 1.day,
        benchmark_type: benchmark_type,
        benchmark_result_type: benchmark_result_type
      )

      benchmark_run2 = create(
        :commit_benchmark_run,
        created_at: time_now,
        benchmark_type: benchmark_type,
        benchmark_result_type: benchmark_result_type
      )

      benchmark_run3 = create(
        :commit_benchmark_run,
        created_at: time_now + 1.day,
        benchmark_type: benchmark_type,
        benchmark_result_type: benchmark_result_type
      )

      visit repo_path(organization_name: @org.name, repo_name: @repo.name)

      within "form" do
        select(benchmark_type.category)
      end

      assert page.has_content?(I18n.t("highcharts.subtitle.commit_url"))

      benchmark_run_line =
        "#{benchmark_run.initiator.sha1}
        #{benchmark_run.initiator.message} -
        #{benchmark_run.result["sometime"]}
        #{benchmark_run.benchmark_result_type.unit}".squish

      benchmark_run2_line =
        "#{benchmark_run2.initiator.sha1}
        #{benchmark_run2.initiator.message} -
        #{benchmark_run2.result["sometime"]}
        #{benchmark_run2.benchmark_result_type.unit}".squish

      benchmark_run3_line =
        "#{benchmark_run3.initiator.sha1}
        #{benchmark_run3.initiator.message} -
        #{benchmark_run3.result["sometime"]}
        #{benchmark_run3.benchmark_result_type.unit}".squish

      markers = page.all(".highcharts-markers.highcharts-tracker path")
      # Markers are found from right to left on the graph
      markers[0].click
      commit = benchmark_run3.initiator

      within_chart_modal_title do
        assert page.has_content?("Commit: #{commit.sha1}")
        assert page.has_content?("Commit Message: #{commit.message}")
        assert page.has_content?(benchmark_run3.environment)
      end

      within_chart_modal_body do
        assert page.has_content?(benchmark_run3_line)
        assert page.has_content?(benchmark_run2_line)
        assert_not page.has_content?(benchmark_run_line)


        assert page.has_selector?(
          github_compare_link(benchmark_run2.initiator, benchmark_run3.initiator)
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
          github_compare_link(benchmark_run.initiator, benchmark_run2.initiator)
        )
      end

      markers[1].click
      commit = benchmark_run2.initiator

      within_chart_modal_title do
        assert page.has_content?("Commit: #{commit.sha1}")
        assert page.has_content?("Commit Message: #{commit.message}")
        assert page.has_content?(benchmark_run2.environment)
      end

      within_chart_modal_body do
        assert page.has_content?(benchmark_run3_line)
        assert page.has_content?(benchmark_run2_line)
        assert page.has_content?(benchmark_run_line)

        assert page.has_selector?(
          github_compare_link(benchmark_run2.initiator, benchmark_run3.initiator)
        )

        assert page.has_selector?(
          github_compare_link(benchmark_run.initiator, benchmark_run2.initiator)
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

  def github_compare_link(commit1, commit2)
    "a[href='https://github.com/#{@org.name}/#{@repo.name}/compare/"\
    "#{commit1.sha1}...#{commit2.sha1}']"
  end
end
