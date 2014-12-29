class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.belongs_to :repo, null: false
      t.string :version, null: false

      t.timestamps null: false
    end
  end
end
