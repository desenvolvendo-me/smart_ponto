class ApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin

  def index
    @positions = User.distinct.pluck(:position).compact.reject(&:blank?).sort

    pending_query = TimeSheet.joins(:user).where(approval_status: 'enviado')
    history_query = TimeSheet.joins(:user).where(approval_status: ['aprovado', 'rejeitado'])

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      pending_query = pending_query.where("users.name LIKE ? OR time_sheets.justification LIKE ?", search_term, search_term)
      history_query = history_query.where("users.name LIKE ? OR time_sheets.justification LIKE ?", search_term, search_term)
    end

    if params[:position].present?
      pending_query = pending_query.where("users.position = ?", params[:position])
      history_query = history_query.where("users.position = ?", params[:position])
    end

    # Calculate pending count after applying filters
    @pending_count = pending_query.count

    @pending_sheets = pending_query.includes(:user)
                                  .chronological
                                  .page(params[:page]).per(10)

    @history_sheets = history_query.includes(:user)
                                  .chronological
                                  .page(params[:page]).per(10)
  end

  def approve
    @time_sheet = TimeSheet.find(params[:id])
    @time_sheet.update(approval_status: 'aprovado',
                       approved_by: current_user.id,
                       approved_at: Time.current)

    redirect_to approvals_path, notice: 'Solicitação aprovada com sucesso!'
  end

  def reject
    @time_sheet = TimeSheet.find(params[:id])
    @time_sheet.update(approval_status: 'rejeitado',
                       approved_by: current_user.id,
                       approved_at: Time.current)

    redirect_to approvals_path, notice: 'Solicitação rejeitada com sucesso!'
  end

  private

  def authorize_manager_or_admin
    unless current_user.role == 'gestor'
      redirect_to root_path, alert: 'Você não tem permissão para acessar esta página.'
    end
  end
end
