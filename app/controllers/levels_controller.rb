class LevelsController < ApplicationController
  before_action :authenticate_user!

  # Level definitions with metadata for each available level
  # Used to display level options and create new level instances
  LEVEL_DEFINITIONS = [
    { key: "level1", name: "Level 1: Building Your Nest Egg", description: "Start your financial journey by learning how to save smart. Make choices that grow your money, avoid common pitfalls, and watch your nest egg take shape. Every decision counts when building a strong foundation for your future wealth!" },
    { key: "level2", name: "Level 2: Passive Income", description: "Take your skills to the next level by learning how to make money work for you. Explore investments, interest, and smart strategies that earn while you focus on other adventures. Can you unlock the secret to steady, hands-off income?" },
    { key: "level3", name: "Level 3: Different Income Streams", description: "Become a true Wealth Wizard by diversifying your income. Manage multiple streams, balance risks and rewards, and discover how to maximize your earnings in the real world. The more you explore, the more your financial empire grows!" }
  ].freeze

  # Displays the levels overview page with game instructions and available levels
  # Shows current active level if user is already progressing through one
  def index
    @current_level = current_user.level
    @levels = LEVEL_DEFINITIONS
  end

  # POST /levels - Starts the user's journey at Level 1: Building Your Nest Egg
  # Only creates a level if there is none or the previous is completed
  def create
    # Use Level 1 as default for entry into the game
    definition = LEVEL_DEFINITIONS.first
    existing_level = current_user.level

    # If already have an active/incomplete level, don't recreate, just move to gameboard
    if existing_level && !existing_level.completion_status
      redirect_to gameboard_path and return
    end

    # Remove existing level if completed (resetting journey)
    current_user.level&.destroy

    new_level = current_user.build_level(
      name: definition[:name],
      description: definition[:description],
      completion_status: false
    )
    if new_level.save
      redirect_to gameboard_path
    else
      redirect_to levels_path, alert: "Could not start the journey."
    end
  end

  private

  # Finds a level definition by key from LEVEL_DEFINITIONS
  def find_level_definition(level_key)
    LEVEL_DEFINITIONS.find { |d| d[:key] == level_key }
  end

  # Checks if the user currently has an active (incomplete) level
  def user_has_active_level?
    existing_level = current_user.level
    existing_level&.completion_status == false
  end

  # Redirects to gameboard if user has an active level
  def redirect_if_active_level_exists
    redirect_to gameboard_path, notice: "You're already progressing through a level."
  end

  # Redirects to levels path with an error message
  def redirect_with_error(message)
    redirect_to levels_path, alert: message
  end

  # Destroys existing level (if any) and creates a new level for the user
  # Redirects to gameboard on success, or back to levels overview on failure
  def replace_or_create_level(definition)
    current_user.level&.destroy

    new_level = current_user.build_level(
      name: definition[:name],
      description: definition[:description],
      completion_status: false
    )

    if new_level.save
      redirect_to gameboard_path, notice: "Level started!"
    else
      redirect_with_error("Could not start the level.")
    end
  end
end
