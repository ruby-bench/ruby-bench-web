class CreateBenchmarkTypes < ActiveRecord::Migration
  def change
    create_table :benchmark_types do |t|
      t.string :category, null: false
      t.string :unit, null: false
      t.string :script_url, null: false
      t.integer :repo_id, null: false

      t.timestamps null: false
    end

    add_index :benchmark_types, :repo_id
    add_index :benchmark_types, [:repo_id, :category, :script_url], unique: true
  end
end
