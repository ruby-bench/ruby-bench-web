class AddRepoIdIndexToReleases < ActiveRecord::Migration
  def change
    add_index :releases, :repo_id
  end
end
