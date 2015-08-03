class AddBenchmarkResultTypeIdToBenchmarkRuns < ActiveRecord::Migration
  def change
    add_column :benchmark_runs, :benchmark_result_type_id, :integer
  end
end
