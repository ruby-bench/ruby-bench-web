class DataAddBenchmarkResultTypeIdToBenchmarkRuns < ActiveRecord::Migration
  def up
    if Rails.env.production?
      ruby_benchmark_types = Repo
        .joins(:organization)
        .where('repos.name = ? AND organizations.name = ?', 'ruby', 'ruby')
        .first
        .benchmark_types

      benchmark_result_type = BenchmarkResultType.create!(
        name: 'Execution time', unit: 'Seconds'
      )

      # Selecting non-memory and non-discourse benchmark types
      ruby_benchmark_types.select do |benchmark_type|
        benchmark_type.category !~ /memory|discourse/
      end.each do |benchmark_type|
        benchmark_type.benchmark_runs.update_all(benchmark_result_type_id: benchmark_result_type.id)
      end

      benchmark_result_type = BenchmarkResultType.create!(
        name: 'RSS memory usage', unit: 'Kilobtyes'
      )

      # Selecting all memory benchmark types
      ruby_benchmark_types.select do |benchmark_type|
        benchmark_type.category =~ /memory/
      end.each do |benchmark_type|
        benchmark_type.benchmark_runs.update_all(benchmark_result_type_id: benchmark_result_type.id)

        # Skip discourse memory benchmarks
        if benchmark_type.category !~ /discourse/
          benchmark_type.category =~ /(.+)_memory\Z/
          new_benchmark_type = BenchmarkType.find_by_category($1)
          benchmark_type.benchmark_runs.update_all(benchmark_type_id: new_benchmark_type.id)
          benchmark_type.destroy
        end
      end

      benchmark_result_type = BenchmarkResultType.create!(
        name: 'Response time', unit: 'Millieseconds'
      )

      # Selecting only discourse benchmark_types
      ruby_benchmark_types.select do |benchmark_type|
        benchmark_type.category =~ /discourse/
      end.reject do |benchmark_type|
        benchmark_type.category =~ /memory/
      end.each do |benchmark_type|
        benchmark_type.benchmark_runs.update_all(benchmark_result_type_id: benchmark_result_type.id)
      end

      # Just wipe all Rails benchmarks since re-running all the benchmarks causes
      # less pain as compared to writing the migration scripts.
      rails_benchmark_types = Repo
        .joins(:organization)
        .where('repos.name = ? AND organizations.name = ?', 'rails', 'rails')
        .first
        .benchmark_types.destroy_all
    end
  end
end
