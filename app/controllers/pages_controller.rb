class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  # Landing page - no authentication required
  def home
    @user = current_user
  end

  # Main gameboard view for playing challenges
  # Special handling for Level 0 users: creates Level 1 and redirects to levels overview (shows Level 1 card)
  # Redirects to levels overview if:
  #   - User has no level yet
  #   - Current level is already completed
  # Otherwise displays challenges for the active level and allows challenge selection
  def gameboard
    # define variables needed, such as user and their current level
    @user = current_user
    @level = @user.level

    # Check if user comes from landingpage to dashboard, if yes show overlay
    referrer_path = URI(request.referrer || "").path rescue nil
    @show_overlay = (referrer_path == root_path)

    # Special case: Level 0 users starting their journey get Level 1 created and shown Level 1 overview page
    if @level&.name == "Level 0"
      # Get Level 1 definition from LevelsController
      level1_def = LevelsController::LEVEL_DEFINITIONS.find { |l| l[:key] == "level1" }
      # Destroy Level 0
      @level.destroy
      # Create Level 1
      @user.create_level!(
        name: level1_def[:name],
        description: level1_def[:description],
        completion_status: false
      )
      # Redirect to levels overview to show Level 1 card instead of going directly to gameboard
      redirect_to levels_path and return
    end

    # Redirect to Levels Overview when starting a new level (no level yet)
    # or when the current level is completed
    redirect_to levels_path and return if @level.nil? || @level.completion_status

    # Load challenges for the active level
    @challenges = @level.challenges

    # Set current challenge: use specified challenge_id from params,
    # or default to the most recently created challenge
    @challenges = @level ? @level.challenges : []

    # check for current challenge ID, if not present take the most recent one
    @challenge =
      if params[:challenge_id].present?
        @challenges.find_by(id: params[:challenge_id])
      else
        @challenges.order(created_at: :desc).first
      end

    # parse prompt to define correct answer and choice numbers
    # convert to string
    prompt = @challenge&.challenge_prompt.to_s

    # parse string using private parse_options, see below
    @challenge_options = parse_options(prompt)

    # get correct number from challenge
    correct_number = @challenge&.correct_answer.to_i

    # get users choice as an integer
    choice_number = @challenge&.choice.to_i
    # Check if answer is correct, is it a positive integer and equal to correct_number
    @answer_is_correct = choice_number.positive? && choice_number == correct_number

    # use the previously parsed prompt to show the correct answer text, checking where the number is equal
    # to the correct option number
    @correct_answer_text =
      if correct_number.positive?
        match = @challenge_options.find { |number, _text| number == correct_number }
        match&.last
      end

    # prepare answer feedback variable, if challenge exists and user has submitted a choice
    # (challenge id contains choice variable)
    @show_answer_feedback = @challenge.present? && @challenge.choice.present?


  end

  def dashboard
    @user = current_user
    @level = @user.level
  end
private

  def parse_options(prompt)
    # take prompt, make it a string, split it by line and strip any white space and map over it
    prompt.to_s.split("\n").map(&:strip)
    # Use regex to only keep lines starting with a digit (d) followed by a .(escaped) followed by space
          .select { |line| line.match?(/^\d+\.\s/) }
          .map do |line|
            # Split each line at the first ., e.g. 1. Do abc becomes ["1", "Do abc"]
            number_str, text = line.split('.', 2).map(&:strip)
            # Convert the number string to an integer -> to be able to compare in @answer_is_correct
            [number_str.to_i, text]
          end
  end
end
