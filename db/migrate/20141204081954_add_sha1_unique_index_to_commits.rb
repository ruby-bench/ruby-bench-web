class AddSha1UniqueIndexToCommits < ActiveRecord::Migration
  def up
    add_index :commits, [:sha1, :repo_id], unique: true
  end

  def down
    remove_index :commits, [:sha1, :repo_id]
  end
end
