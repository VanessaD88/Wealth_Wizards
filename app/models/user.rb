class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_commit :ensure_default_level, on: :create
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

  # check user level based in conditions (methode is called in challenges create)
  def check_level
    if self.balance < 1
      return 0
    elsif self.balance >= 1 && self.balance < 10000
      return 1
    elsif self.balance >= 10000 && self.balance < 30000
      return 2
    elsif self.balance >= 30000 && self.balance <= 40000
      return 3
    else # everything >40000 return 4 -> Game completed
      return 4
    end
  end

  private
  def ensure_default_level
    return if level.present?
    create_level!(
      name: "Level 0",
      description: "Game not started",
      completion_status: false
    )
  end

end
