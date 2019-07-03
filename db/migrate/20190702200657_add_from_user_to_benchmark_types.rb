class AddFromUserToBenchmarkTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :benchmark_types, :from_user, :boolean, null: false, default: false
  end
end
