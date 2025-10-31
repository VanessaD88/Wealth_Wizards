class LevelsController < ApplicationController
  before_action :authenticate_user!

  # LEVEL_DEFINITIONS: Static lookup array for all possible levels, their keys, names, and descriptions.
  # Used for both rendering the correct overview as well as controlling gameplay logic.
  # Level 0 serves as the welcome/introduction level for new users.
  LEVEL_DEFINITIONS = [
    { key: "level0", name: "Level 0", description: "Welcome, Apprentice of Fortune.\n\nEvery wizard begins with a small pouch of starting capital — your seed of potential. What you do with it determines how your story unfolds.\n\nAcross three realms of mastery, you'll face challenges that mirror real-world money choices. In each round, your decisions shape your path: wise moves unlock tougher quests and greater rewards; reckless ones may cost you progress, but reveal valuable lessons.\n\nYou'll learn the spells of saving, investing, and spending with purpose. When you're ready, the real trials begin.\n\nStep forward, Wealth Wizard. The board awaits your first move." },
    { key: "level1", name: "Level 1: Building Your Nest Egg", description: "Start your financial journey by learning how to save smart. Make choices that grow your money, avoid common pitfalls, and watch your nest egg take shape. Every decision counts when building a strong foundation for your future wealth!" },
    { key: "level2", name: "Level 2: Passive Income", description: "Take your skills to the next level by learning how to make money work for you. Explore investments, interest, and smart strategies that earn while you focus on other adventures. Can you unlock the secret to steady, hands-off income?" },
    { key: "level3", name: "Level 3: Different Income Streams", description: "Become a true Wealth Wizard by diversifying your income. Manage multiple streams, balance risks and rewards, and discover how to maximize your earnings in the real world. The more you explore, the more your financial empire grows!" }
  ].freeze

  # GET /levels
  # Shows (at most) one level overview card, with CTA, matching the user's current level.
  # Level 0 displays the welcome/game introduction description for new users.
  def index
    @current_level = current_user.level
    if @current_level && !@current_level.completion_status
      # Find the level definition whose name matches the user's Level record.
      # Level 0 is special: it shows the welcome/intro description instead of gameplay level info
      level_def = LEVEL_DEFINITIONS.find { |lvl| lvl[:name] == @current_level.name }
      @level = level_def || LEVEL_DEFINITIONS.first
      # Icon path (only show icon for Level 1, 2, 3; Level 0 is welcome text only)
      @level_icon = (@level[:key] == "level0") ? nil : "icon_#{@level[:key]}.png"
    else
      # No level yet or last level completed: show the start-your-journey card
      @level = nil
      @level_icon = nil
    end
  end

  # POST /levels
  # Starts a new journey at level 1. Only creates a record if the user has no active/incomplete journey.
  def create
    definition = LEVEL_DEFINITIONS.first
    existing_level = current_user.level
    # If user already has an active (not completed) journey, do not start a new one — redirect to gameboard
    if existing_level && !existing_level.completion_status
      redirect_to gameboard_path and return
    end
    # Remove completed level (reset journey)
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

  # Helper: Find a level definition by key
  def find_level_definition(level_key)
    LEVEL_DEFINITIONS.find { |d| d[:key] == level_key }
  end

  # Helper: Checks if the user has an active, incomplete level
  def user_has_active_level?
    existing_level = current_user.level
    existing_level&.completion_status == false
  end

  # Helper: Redirect to gameboard if user has an active level
  def redirect_if_active_level_exists
    redirect_to gameboard_path, notice: "You're already progressing through a level."
  end

  # Helper: Redirect to levels page with a specific error message
  def redirect_with_error(message)
    redirect_to levels_path, alert: message
  end

  # Helper: Replaces any existing level with a new one based on supplied definition.
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
