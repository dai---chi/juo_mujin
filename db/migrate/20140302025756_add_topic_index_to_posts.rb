class AddTopicIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, [:topic_id, :created_at]
  end
end
