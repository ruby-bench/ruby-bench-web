class RenameBenchmarkResultTypes < ActiveRecord::Migration[5.0]
  def change
    rename_column :benchmark_runs, :benchmark_result_type_id, :result_type_id
    rename_table :benchmark_result_types, :result_types
  end
end
