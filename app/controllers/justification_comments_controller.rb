class JustificationCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_sheet
  before_action :set_comment, only: [:show, :destroy]
  before_action :authorize_view!, only: [:index, :show]
  before_action :authorize_create!, only: [:create]

  def index
    @comments = @time_sheet.comments_thread
    @new_comment = JustificationComment.new
  end

  def create
    @comment = @time_sheet.justification_comments.build(comment_params)
    @comment.user = current_user
    @comment.level = @time_sheet.next_comment_level

    if @comment.save
      redirect_to time_sheet_justification_comments_path(@time_sheet),
                  notice: 'Comentário adicionado com sucesso.'
    else
      @comments = @time_sheet.comments_thread
      @new_comment = @comment
      render :index, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    if can_delete_comment?
      @comment.destroy
      redirect_to time_sheet_justification_comments_path(@time_sheet),
                  notice: 'Comentário removido com sucesso.'
    else
      redirect_to time_sheet_justification_comments_path(@time_sheet),
                  alert: 'Você não tem permissão para remover este comentário.'
    end
  end

  private

  def set_time_sheet
    @time_sheet = TimeSheet.find(params[:time_sheet_id])
  end

  def set_comment
    @comment = @time_sheet.justification_comments.find(params[:id])
  end

  def comment_params
    params.require(:justification_comment).permit(:content)
  end

  def authorize_view!
    # Gerentes podem ver discussões de qualquer justificativa pendente
    # Funcionários só podem ver discussões de suas próprias folhas de ponto
    unless can_view_discussion?
      redirect_to time_sheets_path,
                  alert: 'Você não tem permissão para acessar esta discussão.'
    end
  end

  def authorize_create!
    unless @time_sheet.pending_comment_from?(current_user)
      redirect_to time_sheet_justification_comments_path(@time_sheet),
                  alert: 'Você não tem permissão para comentar neste momento.'
    end
  end

  def can_view_discussion?
    return false unless @time_sheet.can_comment? # Deve estar em status 'pendente'

    # Gerentes podem ver todas as discussões
    return true if current_user.role == 'gestor' || current_user.role == 'admin'

    # Funcionários só podem ver suas próprias discussões
    current_user == @time_sheet.user
  end

  def can_delete_comment?
    return false unless @comment

    # Apenas o autor pode deletar seu próprio comentário
    return false unless @comment.user == current_user

    # Não pode deletar se já existem respostas
    return false if @comment.replies.any?

    # Apenas comentários recentes (últimas 24h) podem ser deletados
    @comment.created_at > 24.hours.ago
  end
end