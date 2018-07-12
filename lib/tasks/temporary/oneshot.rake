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

      if run = benchmark_type.benchmark_runs.where(initiator: commit, benchmark_result_type: type)
        run.destroy
      end
    end
  end
end
