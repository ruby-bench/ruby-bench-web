namespace :oneshot do
  desc 'Remove duplicated commit'
  task remove_duplicates: :environment do
    commit = Commit.find(28796) # unlink commit
    if commit.sha1 != "f2dec4ab9615807b7eaee25e5be24b271e2283b3"
      raise "wrong sha1: #{commit.sha1}"
    end
    type = BenchmarkResultType.find_by(name: 'Execution time', unit: 'Seconds')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
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
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      puts "benchmark_type: #{benchmark_type.id}"
      original_type.benchmark_runs.where(benchmark_result_type: wrong_type).update_all(
        benchmark_result_type_id: right_type.id,
        benchmark_type_id: benchmark_type.id,
      )
    end
  end

  desc 'Remove broken ones'
  task remove_file: :environment do
    BenchmarkType.where(category: 'file_chmod').destroy_all
    BenchmarkType.where(category: 'file_rename').destroy_all
  end

  desc 'Convert time to ips for .rb benchmark'
  task rb_time2ips: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/.+\.rb\z])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      print "benchmark_type: #{benchmark_type.category}"
      original_type.benchmark_runs.where(benchmark_result_type: time_result_type).find_in_batches do |benchmark_runs|
        benchmark_runs.each do |benchmark_run|
          result = {}
          benchmark_run.result.each do |key, value|
            result[key] = 1.0 / Float(value)
          end
          benchmark_run.result = result
          benchmark_run.benchmark_result_type = ips_result_type
        end

        print '.'
        begin
          BenchmarkRun.import!(benchmark_runs, on_duplicate_key_update: [:result, :benchmark_result_type_id])
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.class}: #{e.message}"
        end
      end
      puts
    end
  end

  desc 'Convert time to ips for some .yml'
  task yml_time2ips: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    list = [
      'require_thread.yml',
      'require.yml',
      'so_count_words.yml',
      'so_k_nucleotide.yml',
      'so_reverse_complement.yml',
    ]

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/.+\.yml\z])
        next
      end
      unless list.any? { |str| benchmark_type.script_url.end_with?(str) }
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      print "benchmark_type: #{benchmark_type.category}"
      original_type.benchmark_runs.where(benchmark_result_type: time_result_type).find_in_batches do |benchmark_runs|
        benchmark_runs.each do |benchmark_run|
          result = {}
          benchmark_run.result.each do |key, value|
            result[key] = 1.0 / Float(value)
          end
          benchmark_run.result = result
          benchmark_run.benchmark_result_type = ips_result_type
        end

        print '.'
        begin
          BenchmarkRun.import!(benchmark_runs, on_duplicate_key_update: [:result, :benchmark_result_type_id])
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.class}: #{e.message}"
        end
      end
      puts
    end
  end

  desc 'Remove invalid erb'
  task remove_erb: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    BenchmarkType.where(category: ['app_erb', 'erb_render']).each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/.+\.yml\z])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end
      original_type.benchmark_runs.where(benchmark_result_type: time_result_type).delete_all
    end
  end

  desc 'Convert vm1 to ips'
  task vm1: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/vm1_.+\.yml\z])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      print "benchmark_type: #{benchmark_type.category}"
      original_type.benchmark_runs.where(benchmark_result_type: time_result_type).find_in_batches do |benchmark_runs|
        benchmark_runs.each do |benchmark_run|
          result = {}
          benchmark_run.result.each do |key, value|
            result[key] = 30000000.0 / Float(value)
          end
          benchmark_run.result = result
          benchmark_run.benchmark_result_type = ips_result_type
        end

        print '.'
        begin
          BenchmarkRun.import!(benchmark_runs, on_duplicate_key_update: [:result, :benchmark_result_type_id])
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.class}: #{e.message}"
        end
      end
      puts
    end
  end

  desc 'Convert vm2 to ips'
  task vm2: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/vm2_.+\.yml\z])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      print "benchmark_type: #{benchmark_type.category}"
      original_type.benchmark_runs.where(benchmark_result_type: time_result_type).find_in_batches do |benchmark_runs|
        benchmark_runs.each do |benchmark_run|
          result = {}
          benchmark_run.result.each do |key, value|
            result[key] = 6000000.0 / Float(value)
          end
          benchmark_run.result = result
          benchmark_run.benchmark_result_type = ips_result_type
        end

        print '.'
        begin
          BenchmarkRun.import!(benchmark_runs, on_duplicate_key_update: [:result, :benchmark_result_type_id])
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.class}: #{e.message}"
        end
      end
      puts
    end
  end

  desc 'Remove invalid preview2 2.6.0'
  task remove_26: :environment do
    time_result_type = BenchmarkResultType.find_by!(name: 'Execution time', unit: 'Seconds')
    ips_result_type  = BenchmarkResultType.find_by!(name: 'Iteration per second', unit: 'i/s')

    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      puts "benchmark_type: #{benchmark_type.category}"
      benchmark_type.benchmark_runs.where(benchmark_result_type: time_result_type).delete_all
    end
  end

  desc 'Remove duplicates'
  task final: :environment do
    BenchmarkType.all.each do |benchmark_type|
      unless benchmark_type.script_url.match(%r[\Ahttps://raw\.githubusercontent\.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/])
        next
      end

      original_type = BenchmarkType.where.not(id: benchmark_type.id).find_by(category: benchmark_type.category)
      if original_type.nil? || !original_type.script_url.match(%r[\Ahttps://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_])
        next
      end

      puts "benchmark_type: #{benchmark_type.category}"
      BenchmarkRun.where(benchmark_type: original_type).update_all(benchmark_type_id: benchmark_type.id)
      BenchmarkType.where(id: original_type.id).delete_all
    end
  end
end
