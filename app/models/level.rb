class Level < ApplicationRecord
  belongs_to :user
  has_many :challenges
end
