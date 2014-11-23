class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :sha1, null: false
      t.string :url, null: false
      t.text :message, null: false
      t.integer :repo_id, null: false

      t.timestamps null: false
    end

    add_index :commits, :repo_id
  end
end
