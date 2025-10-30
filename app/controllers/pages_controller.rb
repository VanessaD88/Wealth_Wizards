class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @user= current_user
    @user.avatar
  end

  def gameboard
    @user = current_user
    @level = @user.level
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
