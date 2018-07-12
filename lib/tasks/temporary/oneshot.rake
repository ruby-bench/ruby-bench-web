module RubybenchOneshot
  class << self
  end
end

namespace :oneshot do
  desc 'Remove duplicated commit'
  task remove_duplicates: :environment do
    commit = Commit.find(28796) # unlink commit
    if commit.sha1 != "f2dec4ab9615807b7eaee25e5be24b271e2283b3"
      raise "wrong sha1: #{commit.sha1}"
    end
    type = BenchmarkResultType.find_by(name: 'Execution time', unit: 'Seconds')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
        next
      end

      if run = benchmark_type.benchmark_runs.find_by(initiator: commit, benchmark_result_type: type)
        run.destroy
      end
    end
  end

  desc 'Resolve legacy typo'
  task normalize_rss: :environment do
    wrong_type = BenchmarkResultType.find_by!(name: 'RSS memory usage', unit: 'Kilobtyes')
    right_type = BenchmarkResultType.find_by!(name: 'RSS memory usage', unit: 'Kilobytes')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      puts "benchmark_type: #{benchmark_type.id}"
      original_type.benchmark_runs.where(benchmark_result_type: wrong_type).update_all(
        benchmark_result_type_id: right_type.id,
        benchmark_type_id: benchmark_type.id,
      )
    end
  end
end
