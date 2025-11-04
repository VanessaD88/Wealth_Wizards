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
    difficulty = determine_difficulty

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
      update_user_scores(@level, @challenge)
      level_completion(@challenge)
      # if updates, to back to gameboard/challenge/id and show "answer saved"
      # redirect_to pages_gameboard_path(challenge_id: @challenge.id), notice: "Answer saved."
    else
      # if updates, to back to gameboard/challenge/id, but show alert to pick option
      redirect_to pages_gameboard_path(challenge_id: @challenge.id), alert: "Pick an option before submitting."
    end
  end


  # Vanessa's code to check balance for level completion and update level if neccessary
  def level_completion(challenge)
    level_number = current_user.check_level # "should be" level number according to balance methode in user.rb
    if current_user.level.name.include?(level_number.to_s) # if user level is correct for current balance
      redirect_to pages_gameboard_path(challenge_id: challenge.id), notice: "Answer saved."
    else
      case level_number # nice to have would be to also update the description accordingly
      when 1
        current_user.level.update!(name: "Level 1: Building Your Nest Egg")
        redirect_to pages_gameboard_path(from: "level_up"), notice: "Congratulations! You leveled up!"
      when 2
        current_user.level.update!(name: "Level 2: Passive Income")
        redirect_to pages_gameboard_path(from: "level_up"), notice: "Congratulations! You leveled up!"
      when 3
        current_user.level.update!(name: "Level 3: Different Income Streams")
        redirect_to pages_gameboard_path(from: "level_up"), notice: "Congratulations! You leveled up!"
      when 4
        @current_user.level.update!(name: "Game completed")
        redirect_to pages_gameboard_path(from: "level_up"), notice: "Congratulations! You leveled up!"
      end
    end
  end
  # End Vanessas Code

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

  def update_user_scores(level, challenge)
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

    # check if choice has been saved
    if challenge&.choice.present?
      # check if answer to this challenge id is correct
      answer_correct = challenge.choice.to_i == challenge.correct_answer.to_i
      # define current balance for user or take 0
      current_balance = user.balance || 0
      # take the impact of this challenge, if not available take 0
      impact = challenge.balance_impact || 0
      # here we could add logic to deduct from current balance in case of wrong answer after a certain logic, or level etc
      # new_balance = answer_correct ? (current_balance + impact) : current_balance

      # Updating the users' balance depending on their answer
      if answer_correct
        new_balance = current_balance + impact
      else
        # Count how many wrong choices the user made on the current level
        wrong_answers_count = level.challenges
                             .joins(:level)
                             .where(levels: { user_id: user.id })
                             .where.not(choice: nil)
                             .where.not("challenges.choice = challenges.correct_answer")
                             .count
        # Determine if a deduction is due for the user, depending on their level and amount of wrong choices
        deduction_needed = case level.name
                     when /Level 1/i
                       wrong_answers_count % 3 == 0
                     when /Level 2/i
                       wrong_answers_count % 2 == 0
                     when /Level 3/i
                       true
                     else
                       false
                     end
        # Adjust the user balance
        if deduction_needed
          deduction_amount = 500
          new_balance = current_balance - deduction_amount
        else
          deduction_amount = 0
          new_balance = current_balance
        end
        @deduction_amount = deduction_amount # variable instantiation
        flash[:deduction_amount] = deduction_amount # store deduction amount temporarily in flash to retrieve it in the Pages controller
      end
      user.update!(balance: new_balance)
    end
  end

  def determine_difficulty
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
