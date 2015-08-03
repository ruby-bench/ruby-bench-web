class CreateBenchmarkResultTypes < ActiveRecord::Migration
  def change
    create_table :benchmark_result_types do |t|
      t.string :name, null: false
      t.string :unit, null: false

      t.timestamps null: false
    end

    add_index :benchmark_result_types, [:name, :unit], unique: true
  end
end
