class ChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_level
  before_action :set_challenge, only: [:show, :select_choice]

  def index
    @challenges = @level.challenges
  end

  # In case we want to show individual levels separately
  def show
  end




  def create
    # JSON Output Prompt, use JSON so output can be pardsed
    # This needs to be replaced with smarter logic later on, e.g. if user has completed
    # xx easy questions ,switch to medium
    difficulty = rand(1..3)

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
      - "decision_score_impact": A positive decimal number (e.g., 10.0) representing the score impact of a *correct* choice.
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

    # Create new challenge with parsed data
    @challenge = @level.challenges.new(
      title: challenge_data["title"],
      category: challenge_data["category"],
      difficulty: difficulty,
      challenge_prompt: challenge_data["challenge_prompt"],
      description: challenge_data["description"],
      correct_answer: challenge_data["correct_answer"],
      balance_impact: challenge_data["balance_impact"],
      decision_score_impact: challenge_data["decision_score_impact"],
      feedback: challenge_data["feedback"],
      completion_status: false
    )


    # Vanessa's code to define level completion action
    @user.check_level()
    # Level 1 Goal Balance +10.000€
    if @user.level.name 
    # Level 2
    # Level 3
    # End Vanessas Code

    # Redirect to the gameboard page
    if @challenge.save
      redirect_to pages_gameboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Alex adding changes to enabling selection of choices start
  # Triggered when user clicks submit on gameboard form
  def select_choice
    # Update the @challenge object with choice parameter from form
    if @challenge.update(choice_params)
      # Recalculate decision score based on challenge answers in the current level
      update_user_decision_score(@level)
      # if updates, to back to gameboard/challenge/id and show "answer saved"
      redirect_to pages_gameboard_path(challenge_id: @challenge.id), notice: "Answer saved."
    else
      # if updates, to back to gameboard/challenge/id, but show alert to pick option
      redirect_to pages_gameboard_path(challenge_id: @challenge.id), alert: "Pick an option before submitting."
    end
  end

  # Alex adding changes to enabling selection of choices end


  private

  # Set level to current user level
  def set_level
    # fetch current user level
    @level = current_user.level
    # If level_id is in url and does not match user level, redirect to gameboard
    # and say level not found
    if (params[:level_id].present? && @level.id.to_s != params[:level_id].to_s)
      redirect_to pages_gameboard_path, alert: "Level not found."
      return
    end
  end

  def set_challenge
  @challenge = @level.challenges.find(params[:id])
  end

  def choice_params
  params.require(:challenge).permit(:choice)
  end

  def update_user_decision_score(level)
    user = current_user
    # Count the number of the users completed challenges on their current level
    answered = level.challenges
                  .joins(:level)
                  .where(levels: { user_id: user.id })
                  .where.not(choice: nil)
    total_answered = answered.count

    # Count the number of correctly answered challenges
    if total_answered > 0
      correct_answers = answered.where("challenges.choice = challenges.correct_answer").count
      decision_score = ((correct_answers.to_f / total_answered.to_f) * 100).round(2)
      user.update!(decision_score: decision_score)
    else
      # Reset to zero if user has not answered any challenges
      user.update!(decision_score: 0.0)
    end
  end

end
