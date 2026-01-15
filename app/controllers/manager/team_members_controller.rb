class Manager::TeamMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin
  before_action :set_user, only: [:toggle_weekend_registration]

  def index
    @users = User.order(:name)

    # Filtros
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where("name LIKE ? OR email LIKE ? OR employee_id LIKE ?",
                           search_term, search_term, search_term)
    end

    @users = @users.where(department: params[:department]) if params[:department].present?
    @users = @users.where(position: params[:position]) if params[:position].present?

    if params[:weekend_status].present?
      case params[:weekend_status]
      when 'enabled' then @users = @users.with_weekend_registration
      when 'disabled' then @users = @users.without_weekend_registration
      end
    end

    # Valores para filtros
    @departments = User.distinct.pluck(:department).compact.reject(&:blank?).sort
    @positions = User.distinct.pluck(:position).compact.reject(&:blank?).sort

    # Paginação
    @users = @users.page(params[:page]).per(15)
  end

  def toggle_weekend_registration
    new_status = !@user.weekend_registration_allowed

    if @user.update(weekend_registration_allowed: new_status)
      status_text = new_status ? 'habilitado' : 'desabilitado'
      render json: {
        success: true,
        status: new_status,
        message: "Registro de fim de semana #{status_text} para #{@user.name}"
      }
    else
      render json: {
        success: false,
        message: 'Erro ao atualizar permissão'
      }, status: :unprocessable_entity
    end
  end

  private

  def authorize_manager_or_admin
    unless current_user.role.in?(['gestor', 'admin'])
      redirect_to root_path, alert: 'Você não tem permissão para acessar esta página.'
    end
  end

  def set_user
    @user = User.find(params[:id])
  end
end
