class AddUnitToBenchmarkRuns < ActiveRecord::Migration
  def change
    add_column :benchmark_runs, :unit, :string, null: false
  end
end
