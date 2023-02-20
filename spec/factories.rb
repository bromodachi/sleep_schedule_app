FactoryBot.define do
  factory :user do
    name { "bob" }
  end
  factory :follower do
    followee_id { 1 }
    follower_id { 2 }
    active { 1 }
  end
  factory :sleep_schedule do
    slept_at { DateTime.parse("2023-01-01 20:00:00")}
    woke_up_at { DateTime.parse("2023-01-02 07:00:00")}
    user_id { 1 }
    total_slept_seconds { ((DateTime.parse("2023-01-02 07:00:00") - DateTime.parse("2023-01-01 20:00:00")) * 24 * 60 * 60).to_i }
    created_at { 1.days.ago }
  end
end