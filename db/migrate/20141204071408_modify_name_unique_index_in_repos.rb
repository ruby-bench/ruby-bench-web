class ModifyNameUniqueIndexInRepos < ActiveRecord::Migration
  def up
    remove_index :repos, :name
    add_index :repos, [:name, :organization_id], unique: true
  end

  def down
    remove_index :repos, [:name, :organization_id]
    add_index :repos, :name, unique: true
  end
end
