class ChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_level

  def index
    @challenges = @level.challenges
  end

  def show
    @challenge = Challenge.find(params[:id])
  end

  # POST /challenges with challenge_id param (from gameboard button)
  def create
    # find the challenge the user picked
    @challenge = Challenge.find(params[:challenge_id])

    # ensure challenge belongs to the user's level
    unless @challenge.level_id == @level.id
      redirect_to gameboard_path, alert: "This challenge is not available at your level."
      return
    end

    # Compose the challenge_prompt from schema fields and user context.
    generated_prompt = compose_prompt(current_user, @level, @challenge)

    # Persist the prompt into the challenge's `challenge_prompt` field
    @challenge.update(challenge_prompt: generated_prompt)

    # Redirect to the challenge show page where the user sees the generated prompt
    redirect_to challenge_path(@challenge), notice: "Challenge prepared — good luck!"
  rescue ActiveRecord::RecordNotFound
    redirect_to gameboard_path, alert: "Challenge not found."
  end

  private

  def set_level
    # adjust the selection of the active level to your app logic
    @level = current_user.levels.last
  end

  # Compose a text prompt using only schema fields + simple logic
  def compose_prompt(user, level, challenge)
    # Example composition using schema fields
    header = "Challenge: #{challenge.title} (#{challenge.category} — difficulty: #{challenge.difficulty})"
    context = "Player: #{user.username} — Level: #{level.name}. Balance: #{user.balance}, Decision score: #{user.decision_score}."
    core = if challenge.description.present?
             "Description: #{challenge.description}"
           else
             "Complete the following: make a decision that affects your balance by #{challenge.balance_impact || 0} and your decision score by #{challenge.decision_score_impact || 0}."
           end

    choices = challenge.choice.present? ? "Choices: #{challenge.choice}" : nil
    footer = "On completion, you will get feedback: #{challenge.feedback || 'No feedback configured.'}"

    # Combine parts (no external AI)
    [header, context, core, choices, footer].compact.join("\n\n")
  end
end

# example method to apply impacts
def complete_challenge(challenge, user)
  return if challenge.completion_status

  user.balance += (challenge.balance_impact || 0)
  user.decision_score += (challenge.decision_score_impact || 0)
  user.save!

  challenge.update!(completion_status: true)
end
