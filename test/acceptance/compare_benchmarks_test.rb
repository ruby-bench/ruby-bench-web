require 'acceptance/test_helper'

class CompareBenchmarks < AcceptanceTest
  setup do
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")

    @rails_repo = create(:repo)
    @rails_org = @rails_repo.organization
    @active_record_scope_all = create(:benchmark, repo: @rails_repo)

    @sequel_repo = create(:repo)
    @jeremyevans_org = @sequel_repo.organization
    @sequel_scope_all = create(:benchmark, repo: @sequel_repo)

    @memory_benchmark = create(:result_type, name: 'Memory', unit: 'Kilobytes')
    @ips_benchmark = create(:result_type, name: 'ips', unit: 'ips')

    @rails_commit = create(:commit, repo: @rails_repo)
    @rails_ips_run = create(
      :commit_benchmark_run,
      benchmark: @active_record_scope_all,
      initiator: @rails_commit,
      result_type: @ips_benchmark
    )
    @rails_memory_run = create(
      :commit_benchmark_run,
      benchmark: @active_record_scope_all,
      initiator: @rails_commit,
      result_type: @memory_benchmark
    )

    @sequel_commit = create(:commit, repo: @sequel_repo, created_at: 5.days.ago)
    @sequel_ips_run = create(
      :commit_benchmark_run,
      benchmark: @sequel_scope_all,
      initiator: @sequel_commit,
      result_type: @ips_benchmark
    )
    @sequel_memory_run = create(
      :commit_benchmark_run,
      benchmark: @sequel_scope_all,
      initiator: @sequel_commit,
      result_type: @memory_benchmark
    )

    @commit_dates = [@rails_commit.created_at, @sequel_commit.created_at].map { |date| date.strftime('%Y-%m-%d') }
  end

  test 'User should be able to compare benchmarks across repos' do
    visit commits_path(
      @rails_org.name,
      @rails_repo.name,
      result_type: @active_record_scope_all.label,
      compare_with: @sequel_scope_all.label
    )

    within '#benchmark_run_benchmark_type' do
      select(@active_record_scope_all.label)
    end

    within '#benchmark_run_compare_with' do
      select(@sequel_scope_all.label)
    end

    all('.highcharts-xaxis-labels').each do |xaxis|
      within(xaxis) do
        labels = all('text').map { |x| x.text }

        @commit_dates.each do |commit_date|
          assert_includes(labels, commit_date)
        end
      end
    end
  end

  test 'User should be able to see both scripts' do
    visit commits_path(
      organization_name: @rails_org.name,
      repo_name: @rails_repo.name,
      benchmark_label: @active_record_scope_all.label,
      compare_with: @sequel_scope_all.label
    )

    assert page.has_css?('.codehilite', count: 2)
  end
end
