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
    @challenge = CreateService.new.call(current_user)
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
end
