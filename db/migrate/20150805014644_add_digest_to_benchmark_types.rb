class AddDigestToBenchmarkTypes < ActiveRecord::Migration
  def change
    add_column :benchmark_types, :digest, :string
  end
end
