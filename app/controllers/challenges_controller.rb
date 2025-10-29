class ChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_level

  def index
    @challenges = @level.challenges
  end

  # In case we want to show individual levels separately
  def show
    @challenge = @level.challenges.find(params[:id])
  end




  def create
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
      - "difficulty": An integer from 1 (easy) to 5 (hard).
      - "challenge_prompt": The main question or scenario. This prompt MUST include four numbered answer options (e.g., "1. Do this \n 2. Do that...").
      - "description": A short paragraph providing more story or context (can be an empty string if not needed).
      - "correct_answer": The integer number (1, 2, 3, or 4) corresponding to the correct answer option in the challenge_prompt.
      - "balance_impact": A positive or negative decimal number (e.g., 50.0 or -25.5) representing the financial consequence of a *correct* choice.
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
      difficulty: challenge_data["difficulty"],
      challenge_prompt: challenge_data["challenge_prompt"],
      description: challenge_data["description"],
      choice: challenge_data["choice"],
      balance_impact: challenge_data["balance_impact"],
      decision_score_impact: challenge_data["decision_score_impact"],
      feedback: challenge_data["feedback"],
      completion_status: false
    )

    # Redirect to the gameboard page
    if @challenge.save
      redirect_to pages_gameboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Set level to current user level
  def set_level
    @level = current_user.level
    if @level.nil? || @level.id.to_s != params[:level_id].to_s
      redirect_to gameboard_path, alert: "Level not found."
    end
  end

  def parse_options(prompt)
  prompt.to_s.split("\n").map(&:strip).select { |line| line.match?(/^\d+\.\s/) }
  end
end
