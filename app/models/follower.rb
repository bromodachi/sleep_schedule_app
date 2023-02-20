class Follower < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  validates_presence_of :followee_id, :follower_id
  validate :ids_are_not_the_same

  private
  def ids_are_not_the_same
    if follower_id == followee_id
      errors.add(:follower_id, "is not allowed to follow themselves")
    end
  end
end
