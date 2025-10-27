class Challenge < ApplicationRecord
  belongs_to :level
  has_one :user, through: :level
end
