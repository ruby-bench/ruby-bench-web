class CreateBenchmarkRuns < ActiveRecord::Migration
  def change
    create_table :benchmark_runs do |t|
      t.string :category, null: false
      t.hstore :result, null: false
      t.text :environment, null: false
      t.integer :commit_id, null: false

      t.timestamps null: false
    end

    add_index :benchmark_runs, :commit_id
  end
end
