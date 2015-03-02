class AddDigestToBenchmarkTypes < ActiveRecord::Migration
  def up
    add_column :benchmark_types, :digest, :string, default: '', limit: 40

    BenchmarkType.find_each(batch_size: 20) do |benchmark_type|
      benchmark_script = Net::HTTP.get(URI.parse(benchmark_type.script_url))
      benchmark_type.digest = Digest::SHA1.hexdigest(benchmark_script)
      benchmark_type.save!
    end
  end

  def down
    remove_column :benchmark_types, :digest
  end
end
