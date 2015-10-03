# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ruby = Organization.create!(
  name: 'ruby',
  url: 'https://github.com/ruby/'
)

ruby_repo = Repo.create!(
  name: 'ruby',
  url: 'https://github.com/ruby/ruby',
  organization_id: ruby.id
)

ao_bench = ruby_repo.benchmark_types.create!(
  category: 'ao_bench',
  script_url: 'https://raw.githubusercontent.com/ruby/ruby/trunk/benchmark/bm_app_answer.rb'
)

ab_bench = ruby_repo.benchmark_types.create!(
  category: 'ab_bench',
  script_url: 'https://raw.githubusercontent.com/ruby/ruby/trunk/benchmark/bm_app_answer.rb'
)

ao_benchmark_result_type = BenchmarkResultType.create!(
  name: 'Execution time', unit: 'Seconds'
)

ab_benchmark_result_type = BenchmarkResultType.create!(
  name: 'Response time', unit: 'Millieseconds'
)

10.times do |n|
  commit = Commit.create!(
    sha1: Digest::SHA1.hexdigest("#{n}"),
    url: "http://github.com/#{n}",
    message: 'fix something',
    repo_id: ruby_repo.id
  )

  BenchmarkRun.create!(
    result: { 'ao_bench' => 0.22 },
    environment: 'ruby 2.2.0dev',
    initiator_id: commit.id,
    initiator_type: 'Commit',
    benchmark_type_id: ao_bench.id,
    benchmark_result_type_id: ao_benchmark_result_type.id
  )

  BenchmarkRun.create!(
    result: { 'ab_bench' => 1.23 },
    environment: 'ruby 2.2.0dev',
    initiator_id: commit.id,
    initiator_type: 'Commit',
    benchmark_type_id: ab_bench.id,
    benchmark_result_type_id: ab_benchmark_result_type.id
  )
end

10.times do |n|
  release = Release.create!(version: "#{n}", repo_id: ruby_repo.id)

  BenchmarkRun.create!(
    result: { 'ao_bench' => 0.22 },
    environment: 'ruby 2.2.0dev',
    initiator_id: release.id,
    initiator_type: 'Release',
    benchmark_type_id: ab_bench.id,
    benchmark_result_type_id: ab_benchmark_result_type.id
  )

  BenchmarkRun.create!(
    result: { 'ab_bench' => 1.23 },
    environment: 'ruby 2.2.0dev',
    initiator_id: release.id,
    initiator_type: 'Release',
    benchmark_type_id: ao_bench.id,
    benchmark_result_type_id: ao_benchmark_result_type.id
  )
end
