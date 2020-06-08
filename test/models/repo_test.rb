require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test '#generate_sparkline_data picks first commit from every week' do
    repo = create(:repo)

    mem_res_type = create(:benchmark_result_type, name: 'Memory', unit: 'rss')
    ips_res_type = create(:benchmark_result_type, name: 'Ips', unit: 'i/s')

    type1 = create(:benchmark_type, repo: repo, category: 'Array map')
    type2 = create(:benchmark_type, repo: repo, category: 'String to_i')

    # Week of Mon 18-05-2020 to Sun 24-05-2020
    c1 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 24, 1))
    c2 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 24, 1, 1))
    c3 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 24, 1, 1, 1))

    # Week of Mon 25-05-2020 to Sun 31-05-2020
    c4 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 26))
    c5 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 29))
    c6 = create(:commit, repo: repo, created_at: Time.utc(2020, 5, 30))

    # Week of Mon 01-06-2020 to Sun 07-06-2020
    c7 = create(:commit, repo: repo, created_at: Time.utc(2020, 6, 1))
    c8 = create(:commit, repo: repo, created_at: Time.utc(2020, 6, 2))
    c9 = create(:commit, repo: repo, created_at: Time.utc(2020, 6, 7))

    commits = [c1, c2, c3, c4, c5, c6, c7, c8, c9]
    commits.each_with_index do |commit, index|
      [type1, type2].each do |type|
        create(
          :benchmark_run,
          initiator_id: commit.id,
          initiator_type: 'Commit',
          result: { rss_kb: commit.id },
          benchmark_result_type_id: mem_res_type.id,
          benchmark_type_id: type.id
        )
        create(
          :benchmark_run,
          initiator_id: commit.id,
          initiator_type: 'Commit',
          result: { bench_1: commit.id, bench_2: commit.id + 1 },
          benchmark_result_type_id: ips_res_type.id,
          benchmark_type_id: type.id
        )
      end
    end

    # We should pick the first commit from each week.
    # Since the commits are spread over a period of 3
    # weeks, we should have 3 commits. These commits
    # should be c1, c4 and c7.
    # We will then pick the benchmark_runs records whose
    # initiator_ids are the commits we picked up earlier.
    data = repo.generate_sparkline_data
    assert_equal(
      data,
      'Array map' => [
        {
          benchmark_result_type: 'Ips',
          columns: [
            {
              name: 'bench_1',
              data: [c1.id, c4.id, c7.id]
            },
            {
              name: 'bench_2',
              data: [c1.id + 1, c4.id + 1, c7.id + 1]
            }
          ],
        },
        {
          benchmark_result_type: 'Memory',
          columns: [
            {
              name: 'rss_kb',
              data: [c1.id, c4.id, c7.id]
            }
          ]
        }
      ],
      'String to_i' => [
        {
          benchmark_result_type: 'Ips',
          columns: [
            {
              name: 'bench_1',
              data: [c1.id, c4.id, c7.id]
            },
            {
              name: 'bench_2',
              data: [c1.id + 1, c4.id + 1, c7.id + 1]
            }
          ],
        },
        {
          benchmark_result_type: 'Memory',
          columns: [
            {
              name: 'rss_kb',
              data: [c1.id, c4.id, c7.id]
            }
          ]
        }
      ]
    )
  end
end
