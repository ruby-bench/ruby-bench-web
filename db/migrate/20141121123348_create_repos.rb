class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name, null: false
      t.string :url, null: false

      t.timestamps null: false
    end

    add_index :repos, :name, unique: true
    add_index :repos, :url, unique: true
  end
end
