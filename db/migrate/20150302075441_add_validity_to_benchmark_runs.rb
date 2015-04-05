class AddValidityToBenchmarkRuns < ActiveRecord::Migration
  def change
    add_column :benchmark_runs, :validity, :boolean, default: true
  end
end
