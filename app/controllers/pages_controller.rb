class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  # Landing page - no authentication required
  def home
  end

  # Main gameboard view for playing challenges
  # Redirects to levels overview if:
  #   - User has no level yet (level = 0 scenario)
  #   - Current level is already completed
  # Otherwise displays challenges for the active level and allows challenge selection
  def gameboard
    @user = current_user
    @level = @user.level

    # Redirect to Levels Overview when starting a new level (no level yet)
    # or when the current level is completed
    redirect_to levels_path and return if @level.nil? || @level.completion_status

    # Load challenges for the active level
    @challenges = @level.challenges

    # Set current challenge: use specified challenge_id from params,
    # or default to the most recently created challenge
    @challenges = @level ? @level.challenges : []
    @challenge =
      if params[:challenge_id].present?
        @challenges.find_by(id: params[:challenge_id])
      else
        @challenges.order(created_at: :desc).first
      end
    prompt = @challenge&.challenge_prompt.to_s
    @challenge_options = parse_options(prompt)

  end

  def dashboard
    @user = current_user
    @level = @user.level
  end
private

  def parse_options(prompt)
  prompt.to_s.split("\n").map(&:strip).select { |line| line.match?(/^\d+\.\s/) }
  end
end
