class CreateSleepSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :sleep_schedules do |t|
      t.integer :user_id
      t.datetime :slept_at
      t.datetime :woke_up_at
      t.integer :total_slept_seconds

      t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :sleep_schedules, [:created_at, :total_slept_seconds]
  end
end
