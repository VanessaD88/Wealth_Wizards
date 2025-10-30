class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

has_one :level
has_many :challenges, through: :levels

validates :username, presence: true, uniqueness: true

  AVATARS = {
    "Penny" => "avatars/penny.png",
    "Cash" => "avatars/cash.png",
    "Investo" => "avatars/investo.png",
    "Goldie" => "avatars/goldie.png"
  }.freeze

  def avatar_image
    if avatar.present? && AVATARS.key?(avatar)
      AVATARS[avatar]
    else
      "avatars/default.png"
    end
  end
end
