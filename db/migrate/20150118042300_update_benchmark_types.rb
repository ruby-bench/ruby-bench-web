class UpdateBenchmarkTypes < ActiveRecord::Migration
  def up
    add_column :benchmark_runs, :benchmark_type_id, :integer, null: false, default: 0
    add_index :benchmark_runs, :benchmark_type_id

    BenchmarkRun.find_each(batch_size: 1000) do |benchmark_run|
      benchmark_type = BenchmarkType.find_or_create_by!(
        category: benchmark_run.category,
        unit: benchmark_run.unit,
        repo_id: benchmark_run.initiator.repo.id,
        script_url: benchmark_run.script_url
      )

      benchmark_run.benchmark_type_id = benchmark_type.id
      benchmark_run.save!
    end

    remove_column :benchmark_runs, :category
    remove_column :benchmark_runs, :unit
    remove_column :benchmark_runs, :script_url
  end
end
