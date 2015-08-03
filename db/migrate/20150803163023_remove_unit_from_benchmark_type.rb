class RemoveUnitFromBenchmarkType < ActiveRecord::Migration
  def change
    remove_column :benchmark_types, :unit, :string, null: false
  end
end
