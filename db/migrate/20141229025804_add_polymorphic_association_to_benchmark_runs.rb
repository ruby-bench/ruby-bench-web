class AddPolymorphicAssociationToBenchmarkRuns < ActiveRecord::Migration
  def up
    add_reference :benchmark_runs, :initiator, polymorphic: true, index: true

    BenchmarkRun.find_each(batch_size: 100) do |benchmark_run|
      benchmark_run.initiator_id = benchmark_run.commit_id
      benchmark_run.initiator_type = 'Commit'
      benchmark_run.save!
    end

    remove_column :benchmark_runs, :commit_id
  end

  def down
    add_column :benchmark_runs, :commit_id, :integer, index: true
    remove_reference :benchmark_runs, :initiator, polymorphic: true, index: true
  end
end
