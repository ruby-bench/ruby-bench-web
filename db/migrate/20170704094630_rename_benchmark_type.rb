class RenameBenchmarkType < ActiveRecord::Migration[5.0]
  def change
    rename_column :benchmark_runs, :benchmark_type_id, :benchmark_id
    rename_table :benchmark_types, :benchmarks
  end
end
