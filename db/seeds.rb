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
  { username: "StreamQueen", email: "stream@example.com", balance: 10000, decision_score: 95},
  { username: "RiskRanger", email: "ranger@example.com", balance: 8500, decision_score: 89}
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

users = User.all
level_definitions_cycle = level_definitions.cycle # so users > levels still get something

users.each do |user|
  level_data = level_definitions_cycle.next
  level = Level.create!(
    name: level_data[:name],
    description: level_data[:description],
    completion_status: false,
    user: user
  )
  puts "Created Level #{level.id} for user #{user.id}"
end

# levels = []
# level_definitions.each_with_index do |data, i|
#   users_for_level = User.offset(i * 2).limit(2) # pick two users per level
#   users_for_level.each do |user|
#     levels << Level.create!(
#       name: data[:name],
#       description: data[:description],
#       completion_status: false,
#       user: user
#     )
#   end
# end

puts "Creating challenges..."
challenge_data = [
  # Level 1 challenges
  {
    level_name: "Level 1: Building Your Nest Egg",
    challenges: [
      {
        title: "Emergency Fund Setup",
        category: "Saving",
        difficulty: 1,
        challenge_prompt: "You’ve just received your first paycheck! How much should you save for emergencies?",
        description: "Decide how much to allocate toward your emergency fund versus spending.",
        balance_impact: 200,
        decision_score_impact: 10,
        feedback: "Smart! Building an emergency fund gives you a strong safety net.",
        completion_status: false
      },
      {
        title: "Avoiding Impulse Buys",
        category: "Spending",
        difficulty: 2,
        challenge_prompt: "A new gadget is calling your name... but it’s not in your budget.",
        description: "Decide whether to splurge or save.",
        balance_impact: -150,
        decision_score_impact: 5,
        feedback: "Resisting impulse buys builds discipline — key to growing wealth!",
        completion_status: false
      }
    ]
  },
  # Level 2 challenges
  {
    level_name: "Level 2: Passive Income",
    challenges: [
      {
        title: "Invest or Save?",
        category: "Investing",
        difficulty: 2,
        challenge_prompt: "You’ve saved $1,000. Do you invest it in stocks or keep it in savings?",
        description: "Your decision determines your growth potential and risk.",
        balance_impact: 500,
        decision_score_impact: 15,
        feedback: "A balanced approach between savings and investments is often best.",
        completion_status: false
      },
      {
        title: "Stock Market Strategy",
        category: "Investing",
        difficulty: 3,
        challenge_prompt: "You’ve built up some savings and want to invest in the stock market. Do you go for stable index funds or take a chance on trending individual stocks?",
        description: "Choose your investment approach: steady long-term growth or higher risk with potential for quick gains.",
        balance_impact: 800,
        decision_score_impact: 20,
        feedback: "Diversifying between index funds and individual stocks helps you balance risk and reward — a true wealth wizard move!",
        completion_status: false
      }
    ]
  },
  # Level 3 challenges
  {
    level_name: "Level 3: Different Income Streams",
    challenges: [
      {
        title: "Start a Side Hustle",
        category: "Entrepreneurship",
        difficulty: 3,
        challenge_prompt: "You’re considering launching a small online business.",
        description: "Do you invest time and money into it?",
        balance_impact: 1500,
        decision_score_impact: 25,
        feedback: "Diversifying your income strengthens financial resilience.",
        completion_status: false
      },
      {
        title: "Freelance or Full-Time?",
        category: "Career",
        difficulty: 2,
        challenge_prompt: "Your job offers security, but freelancing promises flexibility.",
        description: "Choose your path wisely to balance stability and growth.",
        choice: 1,
        balance_impact: 1000,
        decision_score_impact: 20,
        feedback: "Multiple streams of income give you long-term security.",
        completion_status: false
      }
    ]
  }
]

challenge_data.each do |set|
  Level.where(name: set[:level_name]).each do |level|
    set[:challenges].each do |ch|
      Challenge.create!(ch.merge(level: level))
    end
  end
end

puts "Seed done! Seeded #{User.count} users, #{Level.count} levels, and #{Challenge.count} challenges."

# Alex Seed file
# users_data = [
#   {
#     email: "ben@example.com",
#     password: "password123",
#     username: "Ben Explorer",
#     balance: 1_000,
#     decision_score: 55,
#     avatar: "ben.png",
#     level: {
#       name: "Level 1: Financial Foundations",
#       description: "Learn the basics of budgeting, saving, and spending wisely.",
#       completion_status: false,
#       challenges: [
#         {
#           title: "Build a Starter Budget",
#           category: "Budgeting",
#           difficulty: 1,
#           description: "Allocate your monthly income across essentials, savings, and fun.",
#           balance_impact: 150,
#           decision_score_impact: 5,
#           feedback: "Track where every dollar goes to avoid overspending."
#         },
#         {
#           title: "Emergency Fund Kickoff",
#           category: "Saving",
#           difficulty: 1,
#           description: "Set aside the first $500 for emergencies.",
#           balance_impact: 500,
#           decision_score_impact: 6,
#           feedback: "An emergency fund keeps surprise costs from derailing progress."
#         },
#         {
#           title: "Trim Subscriptions",
#           category: "Spending",
#           difficulty: 2,
#           description: "Review monthly subscriptions and cancel at least one unused service.",
#           balance_impact: 25,
#           decision_score_impact: 4,
#           feedback: "Small recurring costs add up—revisit them quarterly."
#         },
#         {
#           title: "Cash vs. Card Challenge",
#           category: "Habits",
#           difficulty: 2,
#           description: "Use cash for discretionary spending this week to build awareness.",
#           balance_impact: 40,
#           decision_score_impact: 3,
#           feedback: "Paying with cash can curb impulse buying."
#         },
#         {
#           title: "Bill Negotiator",
#           category: "Saving",
#           difficulty: 3,
#           description: "Call a service provider and negotiate a lower rate or better plan.",
#           balance_impact: 60,
#           decision_score_impact: 7,
#           feedback: "Regularly negotiating bills reduces recurring expenses."
#         }
#       ]
#     }
#   },
#   {
#     email: "bianca@example.com",
#     password: "password123",
#     username: "Bianca Builder",
#     balance: 2_400,
#     decision_score: 68,
#     avatar: "bianca.png",
#     level: {
#       name: "Level 2: Growth & Investments",
#       description: "Expand savings goals and explore diversified investment options.",
#       completion_status: false,
#       challenges: [
#         {
#           title: "401(k) Optimization",
#           category: "Retirement",
#           difficulty: 2,
#           description: "Increase your 401(k) contribution to capture the full employer match.",
#           balance_impact: 200,
#           decision_score_impact: 8,
#           feedback: "Employer matches are free money—avoid leaving them unused."
#         },
#         {
#           title: "Investment Portfolio Checkup",
#           category: "Investing",
#           difficulty: 3,
#           description: "Review asset allocation and rebalance if any class is off by 5%.",
#           balance_impact: 120,
#           decision_score_impact: 9,
#           feedback: "Rebalancing controls risk and keeps long-term goals on track."
#         },
#         {
#           title: "Savings Automation Sprint",
#           category: "Saving",
#           difficulty: 2,
#           description: "Automate transfers toward three-month emergency and vacation funds.",
#           balance_impact: 300,
#           decision_score_impact: 6,
#           feedback: "Automation ensures goals are funded before discretionary spending."
#         },
#         {
#           title: "Risk Tolerance Review",
#           category: "Planning",
#           difficulty: 3,
#           description: "Complete a questionnaire to reassess your personal risk tolerance.",
#           balance_impact: 0,
#           decision_score_impact: 7,
#           feedback: "Aligning investment risk with comfort level reduces panic selling."
#         },
#         {
#           title: "Insurance Audit",
#           category: "Protection",
#           difficulty: 2,
#           description: "Verify health, auto, and renter coverage levels to avoid gaps.",
#           balance_impact: 80,
#           decision_score_impact: 6,
#           feedback: "The right coverage protects assets against unexpected events."
#         }
#       ]
#     }
#   },
#   {
#     email: "chris@example.com",
#     password: "password123",
#     username: "Chris Challenger",
#     balance: 3_800,
#     decision_score: 74,
#     avatar: "chris.png",
#     level: {
#       name: "Level 3: Mastery & Impact",
#       description: "Optimize advanced strategies for wealth growth and legacy planning.",
#       completion_status: false,
#       challenges: [
#         {
#           title: "Tax-Efficient Investing",
#           category: "Taxes",
#           difficulty: 3,
#           description: "Shift assets into tax-advantaged accounts to minimize tax drag.",
#           balance_impact: 260,
#           decision_score_impact: 10,
#           feedback: "Tax efficiency compounds gains over time."
#         },
#         {
#           title: "Philanthropy Blueprint",
#           category: "Giving",
#           difficulty: 4,
#           description: "Draft a charitable giving plan that aligns with personal values.",
#           balance_impact: -150,
#           decision_score_impact: 8,
#           feedback: "Strategic giving amplifies impact and can unlock tax benefits."
#         },
#         {
#           title: "Estate Plan Refresh",
#           category: "Legacy",
#           difficulty: 4,
#           description: "Review wills, beneficiaries, and trusts with a professional advisor.",
#           balance_impact: 0,
#           decision_score_impact: 9,
#           feedback: "Keeping documents current protects dependents and intentions."
#         },
#         {
#           title: "Passive Income Expansion",
#           category: "Investing",
#           difficulty: 3,
#           description: "Evaluate two new passive income streams and select one to pursue.",
#           balance_impact: 400,
#           decision_score_impact: 9,
#           feedback: "Diversified income reduces reliance on a single source."
#         },
#         {
#           title: "Advanced Budget Review",
#           category: "Budgeting",
#           difficulty: 3,
#           description: "Align spending with long-term goals and trim high-cost categories.",
#           balance_impact: 180,
#           decision_score_impact: 8,
#           feedback: "High-level reviews keep lifestyle creep in check."
#         }
#       ]
#     }
#   }
# ]
# users_data.each do |user_data|
#   user = User.find_or_initialize_by(email: user_data[:email])
#   user.username = user_data[:username]
#   user.balance = user_data[:balance]
#   user.decision_score = user_data[:decision_score]
#   user.avatar = user_data[:avatar]
#   user.password = user_data[:password] if user.new_record?
#   user.save!
#   level_data = user_data[:level]
#   level = user.level || user.build_level
#   level.name = level_data[:name]
#   level.description = level_data[:description]
#   level.completion_status = level_data[:completion_status]
#   level.save!
#   level_data[:challenges].each do |challenge_data|
#     challenge = level.challenges.find_or_initialize_by(title: challenge_data[:title])
#     challenge.category = challenge_data[:category]
#     challenge.difficulty = challenge_data[:difficulty]
#     challenge.description = challenge_data[:description]
#     challenge.balance_impact = challenge_data[:balance_impact]
#     challenge.decision_score_impact = challenge_data[:decision_score_impact]
#     challenge.feedback = challenge_data[:feedback]
#     challenge.completion_status = false
#     challenge.save!
#   end
# end
# puts "Seeded #{User.count} users, #{Level.count} levels, and #{Challenge.count} challenges."
