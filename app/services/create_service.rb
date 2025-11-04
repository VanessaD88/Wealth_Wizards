class CreateService

  def call(current_user)
    @level = current_user.level
    # code copied from challenges controller
    difficulty = determine_difficulty(current_user)

        # JSON Output Prompt, use JSON so output can be pardsed
        prompt = <<~PROMPT
          You are a financial education expert creating a challenge for a game.
          The challenge is for a level named: "#{@level.name}"
          (Level description for context: "#{@level.description}")

          Please generate a single financial challenge based on this level.
          You MUST return a single, valid JSON object and nothing else.
          The JSON object must have EXACTLY the following keys:
          - "title": A short, engaging title for the challenge.
          - "category": A single-word category (e.g., "Budgeting", "Investing", "Debt", "Savings").
          - "difficulty": Use the provided Difficulty value (#{difficulty}) instead of choosing your own. Higher difficulty must reflect more complex scenarios, trickier trade-offs, or nuanced financial concepts. Base the complexity on the provided Difficulty value: 1 = introductory, 2 = intermediate, 3 = advanced.
          - "challenge_prompt": The main question or scenario. This prompt MUST include four numbered answer options (e.g., "1. Do this \n 2. Do that...").
          - "description": A short paragraph providing more story or context (can be an empty string if not needed).
          - "correct_answer": The integer number (1, 2, 3, or 4) corresponding to the correct answer option in the challenge_prompt.
          - "balance_impact": A positive integer (in Euros) representing the financial consequence of a *correct* choice. This value MUST be within the range corresponding to the 'difficulty' integer:
              - difficulty == 1: 500 - 1000
              - difficulty == 2: 1000 - 1500
              - difficulty == 3: 1500 - 2000
          - "feedback": A detailed explanation of why the correct choice is the best answer and why the others are incorrect.

          Example of a valid "challenge_prompt" format:
          "What is the best way to start building an emergency fund?
          1. Invest all your money in cryptocurrency.
          2. Open a dedicated high-yield savings account.
          3. Buy a new luxury car on finance.
          4. Pay off all student debt before saving anything."

          Example of a valid "choice" for the above prompt: 2

          JSON:
        PROMPT

        # Set up answer from LLM
        chat_client = RubyLLM.chat
        ai_reply = chat_client.ask(prompt)
        ai_content = ai_reply.content
        challenge_data = JSON.parse(ai_content)

        if challenge_data["description"].blank? || challenge_data["challenge_prompt"].blank?
          redirect_to level_challenges_path(@level)
          return
        end

        # Create new challenge with parsed data
        @challenge = @level.challenges.new(
          title: challenge_data["title"],
          category: challenge_data["category"],
          difficulty: difficulty,
          challenge_prompt: challenge_data["challenge_prompt"],
          description: challenge_data["description"],
          correct_answer: challenge_data["correct_answer"],
          balance_impact: challenge_data["balance_impact"],
          feedback: challenge_data["feedback"],
          completion_status: false
        )
  end

  private

  def determine_difficulty(current_user)
    # Counting how many challenges the user answered on their current level
    count = @level.challenges.joins(:level).where(levels: { user_id: current_user.id }).where.not(choice: nil).count

    # Set difficulty to 1 if user answered 3 or less challenges
    return 1 if count < 4

    # Set difficulty according to the users' decision score
    case current_user.decision_score.to_f
    when 71..Float::INFINITY then 3
    when 30..70 then 2
    else 1
    end
  end
end
