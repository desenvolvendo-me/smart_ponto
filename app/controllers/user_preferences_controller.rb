class UserPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user_preference = current_user.user_preference || current_user.build_user_preference
  end

  def update
    @user_preference = current_user.user_preference || current_user.build_user_preference

    if @user_preference.update(user_preference_params)
      # Adicione log para depuração
      Rails.logger.info "UserPreference atualizado com sucesso: #{@user_preference.attributes.inspect}"
      redirect_to edit_user_preference_path, notice: "Configurações atualizadas com sucesso."
    else
      # Adicione log para erros
      Rails.logger.error "Erro ao atualizar UserPreference: #{@user_preference.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_preference_params
    # Imprima os parâmetros para depuração
    Rails.logger.info "Parâmetros recebidos: #{params.inspect}"

    params.require(:user_preference).permit(
      :phone_number, :secondary_email, :language,
      :theme, :date_format, :time_format, :first_day_of_week,
      :require_password_on_sign
    )
  end
end