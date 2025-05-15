class ApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin

  def index
    @pending_count = TimeSheet.where(approval_status: 'enviado').count

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @pending_sheets = TimeSheet.joins(:user)
                                 .where(approval_status: 'enviado')
                                 .where("users.name LIKE ? OR time_sheets.justification LIKE ?", search_term, search_term)
                                 .includes(:user)
                                 .chronological
                                 .page(params[:page]).per(10)

      @history_sheets = TimeSheet.joins(:user)
                                 .where(approval_status: ['aprovado', 'rejeitado'])
                                 .where("users.name LIKE ? OR time_sheets.justification LIKE ?", search_term, search_term)
                                 .includes(:user)
                                 .chronological
                                 .page(params[:page]).per(10)
    else
      @pending_sheets = TimeSheet.where(approval_status: 'enviado')
                                 .includes(:user)
                                 .chronological
                                 .page(params[:page]).per(10)

      @history_sheets = TimeSheet.where(approval_status: ['aprovado', 'rejeitado'])
                                 .includes(:user)
                                 .chronological
                                 .page(params[:page]).per(10)
    end
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