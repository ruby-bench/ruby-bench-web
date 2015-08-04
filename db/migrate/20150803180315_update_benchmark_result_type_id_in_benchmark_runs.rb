class UpdateBenchmarkResultTypeIdInBenchmarkRuns < ActiveRecord::Migration
  def up
    change_column_null :benchmark_runs, :benchmark_result_type_id, false
  end

  def down
    change_column_null :benchmark_runs, :benchmark_result_type_id, true
  end
end
