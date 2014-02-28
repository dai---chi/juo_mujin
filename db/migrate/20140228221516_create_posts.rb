class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :content
      t.integer :user_id
      t.integer :parent_node_id
      t.datetime :deleted_at
      t.integer :desire

      t.timestamps
    end
  end
end
