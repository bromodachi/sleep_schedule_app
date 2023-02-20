class CreateFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :followers do |t|
      t.integer :follower_id
      t.integer :followee_id
      t.boolean :active

      t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
    end
    # active can be a part of this to make it a covered index.
    add_index :followers, [:follower_id, :followee_id], unique: true
  end
end
