class ChangeValidityOnBenchmarkRuns < ActiveRecord::Migration[5.0]
  def change
    change_column :benchmark_runs, :validity, :boolean, default: true, null: false
    BenchmarkRun.where("validity IS NULL").update_all(validity: true)
  end
end
