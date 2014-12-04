class AddOrganizationIdToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :organization_id, :integer, null: false
    add_index :repos, :organization_id
  end
end
