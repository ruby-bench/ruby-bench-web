class CreateJoinTableBenchmarkTypeGroup < ActiveRecord::Migration[5.0]
  def change
    create_join_table :benchmark_types, :groups do |t|
      t.index [:benchmark_type_id, :group_id]
      t.index [:group_id, :benchmark_type_id]
    end
  end
end
