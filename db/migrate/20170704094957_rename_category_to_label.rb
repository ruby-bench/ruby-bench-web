class RenameCategoryToLabel < ActiveRecord::Migration[5.0]
  def change
    rename_column :benchmarks, :category, :label
  end
end
