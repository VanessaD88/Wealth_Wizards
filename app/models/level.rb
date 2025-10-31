class Level < ApplicationRecord
  belongs_to :user
  # dependent: :destroy ensures challenges are deleted when level is destroyed
  # This prevents foreign key violations when transitioning from Level 0 to Level 1
  has_many :challenges, dependent: :destroy
end
