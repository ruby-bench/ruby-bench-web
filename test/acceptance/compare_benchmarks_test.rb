require 'acceptance/test_helper'

class CompareBenchmarks < AcceptanceTest
  setup do
    Net::HTTP.stubs(:get).returns("def abc\n  puts haha\nend")

    @rails_repo = create(:repo)
    @rails_org = @rails_repo.organization
    @active_record_scope_all = create(:benchmark_type, repo: @rails_repo)

    @sequel_repo = create(:repo)
    @jeremyevans_org = @sequel_repo.organization
    @sequel_scope_all = create(:benchmark_type, repo: @sequel_repo)

    @memory_benchmark = create(:benchmark_result_type, name: 'Memory', unit: 'Kilobytes')
    @ips_benchmark = create(:benchmark_result_type, name: 'ips', unit: 'ips')

    @rails_commit = create(:commit, repo: @rails_repo)
    @rails_ips_run = create(
      :commit_benchmark_run,
      benchmark_type: @active_record_scope_all,
      initiator: @rails_commit,
      benchmark_result_type: @ips_benchmark
    )
    @rails_memory_run = create(
      :commit_benchmark_run,
      benchmark_type: @active_record_scope_all,
      initiator: @rails_commit,
      benchmark_result_type: @memory_benchmark
    )

    @sequel_commit = create(:commit, repo: @sequel_repo, created_at: 5.days.ago)
    @sequel_ips_run = create(
      :commit_benchmark_run,
      benchmark_type: @sequel_scope_all,
      initiator: @sequel_commit,
      benchmark_result_type: @ips_benchmark
    )
    @sequel_memory_run = create(
      :commit_benchmark_run,
      benchmark_type: @sequel_scope_all,
      initiator: @sequel_commit,
      benchmark_result_type: @memory_benchmark
    )

    visit commits_path(
      @rails_org.name,
      @rails_repo.name,
    )

    within '#benchmark_run_benchmark_type' do
      select(@active_record_scope_all.category)
    end

    within '#benchmark_run_compare_with' do
      select(@sequel_scope_all.category)
    end
  end

  test 'User should be able to see all series for benchmarks selected' do
    assert find(".chart[data-type='#{@ips_benchmark.name}']")['data-series'],
      [
        {
          name: @active_record_scope_all.category,
          data: [
            [@rails_ips_run.initiator.created_at.to_i * 1000, @rails_ips_run.result.values[0]]
          ]
        },
        {
          name: @sequel_scope_all.category,
          data: [
            [@sequel_ips_run.initiator.created_at.to_i * 1000, @sequel_ips_run.result.values[0]]
          ]
        }
      ]

    assert find(".chart[data-type='#{@memory_benchmark.name}']")['data-series'],
      [
        {
          name: @active_record_scope_all.category,
          data: [
            [@rails_memory_run.initiator.created_at.to_i * 1000, @rails_memory_run.result.values[0]]
          ]
        },
        {
          name: @sequel_scope_all.category,
          data: [
            [@sequel_ips_run.initiator.created_at.to_i * 1000, @sequel_ips_run.result.values[0]]
          ]
        }
      ]
  end

  test 'User should be able to follow links to github commits' do
    assert find(".chart[data-type='#{@ips_benchmark.name}']")['data-commit-urls'],
      [
        {
          name: @active_record_scope_all.category,
          data: [
            "https://github.com/#{@rails_org.name}/#{@rails_repo.name}/commit/#{@rails_ips_run.initiator.sha1}",
            "https://github.com/#{@jeremyevans_org.name}/#{@sequel_repo.name}/commit/#{@sequel_ips_run.initiator.sha1}"
          ]
        }
      ]

    assert find(".chart[data-type='#{@memory_benchmark.name}']")['data-commit-urls'],
      [
        {
          name: @active_record_scope_all.category,
          data: [
            "https://github.com/#{@rails_org.name}/#{@rails_repo.name}/commit/#{@rails_memory_run.initiator.sha1}",
            "https://github.com/#{@jeremyevans_org.name}/#{@sequel_repo.name}/commit/#{@sequel_memory_run.initiator.sha1}"
          ]
        }
      ]
  end

  test 'User should be able to see both scripts' do
    visit commits_path(
      organization_name: @rails_org.name,
      repo_name: @rails_repo.name,
      result_type: @active_record_scope_all.category,
      compare_with: @sequel_scope_all.category
    )

    assert page.has_css?('.codehilite', count: 2)
  end
end
