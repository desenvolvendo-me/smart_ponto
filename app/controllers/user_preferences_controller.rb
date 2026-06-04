class UserPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user_preference = current_user.user_preference || current_user.build_user_preference
  end

  def update
    @user_preference = current_user.user_preference || current_user.build_user_preference

    if @user_preference.update(user_preference_params)
      redirect_to edit_user_preference_path, notice: "Configurações atualizadas com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_preference_params
    params.require(:user_preference).permit(
      :phone_number, :secondary_email, :language,
      :theme, :date_format, :time_format, :first_day_of_week,
      :require_password_on_sign
    )
  end
end
