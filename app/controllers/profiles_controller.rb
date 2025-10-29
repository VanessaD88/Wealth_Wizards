class ProfilesController < ApplicationController

  def show
    @user = params[:id].present? ? User.find(params[:id]) : current_user
  end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Avatar updated"
    else
      @user = current_user
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:avatar)
  end
end
