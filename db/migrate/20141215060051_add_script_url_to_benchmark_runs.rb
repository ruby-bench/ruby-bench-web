class AddScriptUrlToBenchmarkRuns < ActiveRecord::Migration
  def change
    add_column :benchmark_runs, :script_url, :string
  end
end
