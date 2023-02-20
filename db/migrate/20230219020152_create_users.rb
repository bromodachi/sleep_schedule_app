class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name

      t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
