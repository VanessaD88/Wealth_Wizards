class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
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
    correct_number = @challenge&.correct_answer.to_i
    choice_number = @challenge&.choice.to_i
    @answer_is_correct = choice_number.positive? && choice_number == correct_number
    @correct_answer_text =
      if correct_number.positive?
        match = @challenge_options.find { |line| line.start_with?("#{correct_number}.") }
        match&.split('.', 2)&.last&.strip
      end
    @show_answer_feedback = @challenge.present? && @challenge.choice.present?


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
