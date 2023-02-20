class SleepSchedule < ApplicationRecord
  belongs_to :user
  validate :woke_up_after_slept

  def woke_up_after_slept
    if woke_up_at.present? && slept_at.present? && woke_up_at <= slept_at
      errors.add(:woke_up_at, "must be greater than slept_at")
    end
  end
end
