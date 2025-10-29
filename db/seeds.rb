
users_data = [
  {
    email: "ben@example.com",
    password: "password123",
    username: "Ben Explorer",
    balance: 1_000,
    decision_score: 55,
    avatar: "ben.png",
    level: {
      name: "Level 1: Financial Foundations",
      description: "Learn the basics of budgeting, saving, and spending wisely.",
      completion_status: false,
      challenges: [
        {
          title: "Build a Starter Budget",
          category: "Budgeting",
          difficulty: 1,
          description: "Allocate your monthly income across essentials, savings, and fun.",
          balance_impact: 150,
          decision_score_impact: 5,
          feedback: "Track where every dollar goes to avoid overspending."
        },
        {
          title: "Emergency Fund Kickoff",
          category: "Saving",
          difficulty: 1,
          description: "Set aside the first $500 for emergencies.",
          balance_impact: 500,
          decision_score_impact: 6,
          feedback: "An emergency fund keeps surprise costs from derailing progress."
        },
        {
          title: "Trim Subscriptions",
          category: "Spending",
          difficulty: 2,
          description: "Review monthly subscriptions and cancel at least one unused service.",
          balance_impact: 25,
          decision_score_impact: 4,
          feedback: "Small recurring costs add up—revisit them quarterly."
        },
        {
          title: "Cash vs. Card Challenge",
          category: "Habits",
          difficulty: 2,
          description: "Use cash for discretionary spending this week to build awareness.",
          balance_impact: 40,
          decision_score_impact: 3,
          feedback: "Paying with cash can curb impulse buying."
        },
        {
          title: "Bill Negotiator",
          category: "Saving",
          difficulty: 3,
          description: "Call a service provider and negotiate a lower rate or better plan.",
          balance_impact: 60,
          decision_score_impact: 7,
          feedback: "Regularly negotiating bills reduces recurring expenses."
        }
      ]
    }
  },
  {
    email: "bianca@example.com",
    password: "password123",
    username: "Bianca Builder",
    balance: 2_400,
    decision_score: 68,
    avatar: "bianca.png",
    level: {
      name: "Level 2: Growth & Investments",
      description: "Expand savings goals and explore diversified investment options.",
      completion_status: false,
      challenges: [
        {
          title: "401(k) Optimization",
          category: "Retirement",
          difficulty: 2,
          description: "Increase your 401(k) contribution to capture the full employer match.",
          balance_impact: 200,
          decision_score_impact: 8,
          feedback: "Employer matches are free money—avoid leaving them unused."
        },
        {
          title: "Investment Portfolio Checkup",
          category: "Investing",
          difficulty: 3,
          description: "Review asset allocation and rebalance if any class is off by 5%.",
          balance_impact: 120,
          decision_score_impact: 9,
          feedback: "Rebalancing controls risk and keeps long-term goals on track."
        },
        {
          title: "Savings Automation Sprint",
          category: "Saving",
          difficulty: 2,
          description: "Automate transfers toward three-month emergency and vacation funds.",
          balance_impact: 300,
          decision_score_impact: 6,
          feedback: "Automation ensures goals are funded before discretionary spending."
        },
        {
          title: "Risk Tolerance Review",
          category: "Planning",
          difficulty: 3,
          description: "Complete a questionnaire to reassess your personal risk tolerance.",
          balance_impact: 0,
          decision_score_impact: 7,
          feedback: "Aligning investment risk with comfort level reduces panic selling."
        },
        {
          title: "Insurance Audit",
          category: "Protection",
          difficulty: 2,
          description: "Verify health, auto, and renter coverage levels to avoid gaps.",
          balance_impact: 80,
          decision_score_impact: 6,
          feedback: "The right coverage protects assets against unexpected events."
        }
      ]
    }
  },
  {
    email: "chris@example.com",
    password: "password123",
    username: "Chris Challenger",
    balance: 3_800,
    decision_score: 74,
    avatar: "chris.png",
    level: {
      name: "Level 3: Mastery & Impact",
      description: "Optimize advanced strategies for wealth growth and legacy planning.",
      completion_status: false,
      challenges: [
        {
          title: "Tax-Efficient Investing",
          category: "Taxes",
          difficulty: 3,
          description: "Shift assets into tax-advantaged accounts to minimize tax drag.",
          balance_impact: 260,
          decision_score_impact: 10,
          feedback: "Tax efficiency compounds gains over time."
        },
        {
          title: "Philanthropy Blueprint",
          category: "Giving",
          difficulty: 4,
          description: "Draft a charitable giving plan that aligns with personal values.",
          balance_impact: -150,
          decision_score_impact: 8,
          feedback: "Strategic giving amplifies impact and can unlock tax benefits."
        },
        {
          title: "Estate Plan Refresh",
          category: "Legacy",
          difficulty: 4,
          description: "Review wills, beneficiaries, and trusts with a professional advisor.",
          balance_impact: 0,
          decision_score_impact: 9,
          feedback: "Keeping documents current protects dependents and intentions."
        },
        {
          title: "Passive Income Expansion",
          category: "Investing",
          difficulty: 3,
          description: "Evaluate two new passive income streams and select one to pursue.",
          balance_impact: 400,
          decision_score_impact: 9,
          feedback: "Diversified income reduces reliance on a single source."
        },
        {
          title: "Advanced Budget Review",
          category: "Budgeting",
          difficulty: 3,
          description: "Align spending with long-term goals and trim high-cost categories.",
          balance_impact: 180,
          decision_score_impact: 8,
          feedback: "High-level reviews keep lifestyle creep in check."
        }
      ]
    }
  }
]

users_data.each do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email])
  user.username = user_data[:username]
  user.balance = user_data[:balance]
  user.decision_score = user_data[:decision_score]
  user.avatar = user_data[:avatar]
  user.password = user_data[:password] if user.new_record?
  user.save!

  level_data = user_data[:level]
  level = user.level || user.build_level
  level.name = level_data[:name]
  level.description = level_data[:description]
  level.completion_status = level_data[:completion_status]
  level.save!

  level_data[:challenges].each do |challenge_data|
    challenge = level.challenges.find_or_initialize_by(title: challenge_data[:title])
    challenge.category = challenge_data[:category]
    challenge.difficulty = challenge_data[:difficulty]
    challenge.description = challenge_data[:description]
    challenge.balance_impact = challenge_data[:balance_impact]
    challenge.decision_score_impact = challenge_data[:decision_score_impact]
    challenge.feedback = challenge_data[:feedback]
    challenge.completion_status = false
    challenge.save!
  end
end

puts "Seeded #{User.count} users, #{Level.count} levels, and #{Challenge.count} challenges."
