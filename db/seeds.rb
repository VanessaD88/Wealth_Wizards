puts "Cleaning database..."
Challenge.destroy_all
Level.destroy_all
User.destroy_all

puts "Seeding database..."

puts "Creating users..."
users = [
  { username: "SageSaver", email: "sage@example.com", balance: 1500, decision_score: 75},
  { username: "MoneyMaven", email: "maven@example.com", balance: 1800, decision_score: 82},
  { username: "InvestorIvy", email: "ivy@example.com", balance: 5000, decision_score: 90},
  { username: "PassivePete", email: "pete@example.com", balance: 4200, decision_score: 84},
  { username: "StreamQueen", email: "stream@example.com", balance: 100000, decision_score: 95},
  { username: "RiskRanger", email: "ranger@example.com", balance: 8500, decision_score: 89},

  { username: "Moonmuffin", email: "moonmuffin@mail.com", balance: 29550, decision_score: 30},
  { username: "Hexalot", email: "hex@mail.com", balance: 29550, decision_score: 30},
  { username: "Fizzlebang ", email: "fizzle@mail.com ", balance: 29550, decision_score: 30},
  { username: "HocusBrokus", email: "hocusbrokus@mail.com", balance: 29550, decision_score: 30},
  { username: "ProfitusMaxima", email: "profitusmaxima@mail.com", balance: 29550, decision_score: 30},
  { username: "AccioAssets", email: "accioassets@mail.com", balance: 29550, decision_score: 30},
  { username: "Budgetbasilisk", email: "budgetbasilisk@mail.com", balance: 29550, decision_score: 30},
  { username: "GalleonGuru", email: "galleonguru@mail.com", balance: 29550, decision_score: 30}
]

users.each do |user_data|
  User.create!(
    user_data.merge(
      password: "password123",
      password_confirmation: "password123"
    )
  )
end

puts "Creating levels..."
level_definitions = [
  {
    name: "Level 1: Building Your Nest Egg",
    description: "Start your financial journey by learning how to save smart. Make choices that grow your money, avoid common pitfalls, and watch your nest egg take shape. Every decision counts when building a strong foundation for your future wealth!"
  },
  {
    name: "Level 2: Passive Income",
    description: "Take your skills to the next level by learning how to make money work for you. Explore investments, interest, and smart strategies that earn while you focus on other adventures. Can you unlock the secret to steady, hands-off income?"
  },
  {
    name: "Level 3: Different Income Streams",
    description: "Become a true Wealth Wizard by diversifying your income. Manage multiple streams, balance risks and rewards, and discover how to maximize your earnings in the real world. The more you explore, the more your financial empire grows!"
  }
]

User.all.each do |user|
  level_info =
    if user.balance.to_f < 10_000
      level_definitions[0]
    elsif user.balance.to_f < 30_000
      level_definitions[1]
    else
      level_definitions[2]
    end

   if user.level.present?
    user.level.update!(
      name: level_info[:name],
      description: level_info[:description],
      completion_status: false
    )
  else
    user.create_level!(
      name: level_info[:name],
      description: level_info[:description],
      completion_status: false
    )
  end
end

puts "Seed done! Seeded #{User.count} users, #{Level.count} levels, and #{Challenge.count} challenges."
