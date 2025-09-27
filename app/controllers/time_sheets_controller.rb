class TimeSheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_sheet, only: [:show, :approve, :submit_for_approval, :sign, :add_justification, :review_justification]
  before_action :check_not_approved, only: [:submit_for_approval, :sign, :add_justification, :review_justification]

  def index
    @time_sheets = current_user.time_sheets
                               .includes(:time_entries)
                               .order(date: :desc)
                               .page(params[:page])
                               .per(10)
  end

  def show
    @time_entries = @time_sheet.time_entries.order(:time)
  end

  def calendar
    @date = if params[:month] && params[:year]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.today.beginning_of_month
            end

    @time_sheets = current_user.time_sheets
                               .where(date: @date.beginning_of_month..@date.end_of_month)
                               .includes(:time_entries)

    @time_sheets_by_date = @time_sheets.index_by(&:date)

    first_day = @date.beginning_of_month.beginning_of_week(:sunday)
    last_day = @date.end_of_month.end_of_week(:sunday)
    @calendar_days = (first_day..last_day).to_a
  end

  def export_form
    # Esta ação apenas renderiza o formulário de exportação
    render 'export'
  end

  def export_preview
    # Definir datas padrão se não forem fornecidas
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # Iniciar a consulta com o filtro de período
    @time_sheets = current_user.time_sheets.where(date: start_date..end_date)

    # Aplicar filtro de status de aprovação se fornecido
    if params[:status].present?
      @time_sheets = @time_sheets.where(approval_status: params[:status])
    end

    # Aplicar filtro de completude se fornecido
    if params[:complete].present?
      @time_sheets = @time_sheets.where(status: params[:complete])
    end

    # Ordenar por data decrescente - mostrar todos os registros filtrados na prévia
    @time_sheets = @time_sheets.order(date: :desc)

    respond_to do |format|
      format.json do
        render json: {
          preview_data: @time_sheets.map do |sheet|
            entries = sheet.time_entries.order(:time)
            times = entries.map { |e| e.time.strftime("%H:%M") }
            while times.length < 4
              times << "-"
            end

            {
              date: sheet.date.strftime("%d/%m/%Y"),
              times: times,
              total_hours: "#{sheet.total_hours.to_f}h",
              approval_status: sheet.approval_status,
              approval_status_label: case sheet.approval_status
                                     when 'aprovado' then 'Aprovado'
                                     when 'enviado' then 'Enviado'
                                     when 'rejeitado' then 'Rejeitado'
                                     else 'Pendente'
                                     end,
              approval_status_class: case sheet.approval_status
                                     when 'aprovado' then 'bg-green-100 text-green-800'
                                     when 'enviado' then 'bg-blue-100 text-blue-800'
                                     when 'rejeitado' then 'bg-red-100 text-red-800'
                                     else 'bg-gray-100 text-gray-800'
                                     end
            }
          end
        }
      end
    end
  end

  def export
    # Definir datas padrão se não forem fornecidas
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # Iniciar a consulta com o filtro de período
    @time_sheets = current_user.time_sheets.where(date: start_date..end_date)

    # Aplicar filtro de status de aprovação se fornecido
    if params[:status].present?
      @time_sheets = @time_sheets.where(approval_status: params[:status])
    end

    # Aplicar filtro de completude se fornecido
    if params[:complete].present?
      @time_sheets = @time_sheets.where(status: params[:complete])
    end

    # Ordenar por data decrescente
    @time_sheets = @time_sheets.order(date: :desc)

    # Preparar o nome do arquivo
    filename_base = "registros-#{start_date.strftime('%d-%m-%Y')}-ate-#{end_date.strftime('%d-%m-%Y')}"

    respond_to do |format|
      format.csv do
        send_data TimeSheet.to_csv(@time_sheets), filename: "#{filename_base}.csv"
      end

      # Adicionar suporte para exportação Excel
      format.xlsx do
        if defined?(Axlsx)
          # Se a gem Axlsx estiver disponível, usar para gerar Excel
          send_data generate_excel(@time_sheets), filename: "#{filename_base}.xlsx"
        else
          # Fallback para CSV se Axlsx não estiver disponível
          send_data TimeSheet.to_csv(@time_sheets), filename: "#{filename_base}.csv"
          flash[:notice] = "Exportação Excel não disponível. Arquivo CSV gerado."
        end
      end

      # Fallback para CSV se o formato não for especificado
      format.any do
        send_data TimeSheet.to_csv(@time_sheets), filename: "#{filename_base}.csv"
      end
    end
  end

  # Método para gerar arquivo Excel
  def generate_excel(time_sheets)
    require 'axlsx'

    package = Axlsx::Package.new
    workbook = package.workbook

    # Adicionar uma planilha
    workbook.add_worksheet(name: "Registros de Ponto") do |sheet|
      # Estilo para o cabeçalho
      header_style = workbook.styles.add_style(
        bg_color: "4F46E5", 
        fg_color: "FFFFFF", 
        b: true, 
        alignment: { horizontal: :center }
      )

      # Adicionar cabeçalho
      sheet.add_row [
        'Data', 
        'Entrada 1', 
        'Saída 1', 
        'Entrada 2', 
        'Saída 2', 
        'Total de Horas', 
        'Status de Aprovação',
        'Status de Completude'
      ], style: header_style

      # Adicionar dados
      time_sheets.each do |time_sheet|
        entries = time_sheet.time_entries.order(:time)
        times = entries.map { |e| e.time.strftime("%H:%M") }

        # Garantir que temos 4 horários (ou "-" para valores ausentes)
        while times.length < 4
          times << "-"
        end

        # Adicionar linha com dados
        sheet.add_row [
          time_sheet.date.strftime("%d/%m/%Y"),
          times[0],
          times[1],
          times[2],
          times[3],
          "#{time_sheet.total_hours}h",
          I18n.t("approval_status.#{time_sheet.approval_status}", default: time_sheet.approval_status.capitalize),
          I18n.t("status.#{time_sheet.status}", default: time_sheet.status.capitalize)
        ]
      end

      # Ajustar largura das colunas automaticamente
      sheet.column_widths 15, 15, 15, 15, 15, 15, 20, 20
    end

    # Retornar o arquivo Excel como string
    package.to_stream.read
  rescue LoadError => e
    # Se a gem axlsx não estiver disponível
    Rails.logger.error "Erro ao gerar Excel: #{e.message}"
    time_sheets.to_csv
  end

  def submit_for_approval
    # Verifica se está dentro da tolerância
    if @time_sheet.within_tolerance?
      # Se estiver dentro da tolerância, atualiza o status para 'enviado'
      @time_sheet.update(approval_status: 'enviado')
      return_path = determine_return_path
      redirect_to return_path, notice: 'Registro enviado para aprovação. Dentro da tolerância de 15 minutos.'
    elsif @time_sheet.justification.present?
      # Se tiver justificativa, atualiza os status
      @time_sheet.update(approval_status: 'enviado', justification_status: 'pendente')
      return_path = determine_return_path
      redirect_to return_path, notice: 'Registro com justificativa enviado para aprovação.'
    else
      # Se estiver fora da tolerância e sem justificativa, exige justificativa
      return_path = determine_return_path
      redirect_to time_sheet_path(@time_sheet), alert: 'É necessário adicionar uma justificativa para diferenças maiores que 15 minutos.'
    end
  end

  def sign
    @time_sheet.update(signature: true)

    return_path = determine_return_path
    redirect_to return_path, notice: 'Registro assinado digitalmente.'
  end

  def add_justification
    if @time_sheet.update(justification: params[:time_sheet][:justification],
                          justification_status: 'pendente')
      # Determina para onde redirecionar com base no parâmetro opcional
      redirect_to params[:return_to] == 'show' ? time_sheet_path(@time_sheet) : time_sheets_path,
                  notice: 'Justificativa adicionada com sucesso.'
    else
      # Se houver erro, volta para a página de detalhes
      render :show, status: :unprocessable_entity,
             alert: 'Erro ao adicionar justificativa: ' + @time_sheet.errors.full_messages.join(', ')
    end
  end

  def review_justification
    status = params[:status] # 'aprovada' ou 'rejeitada'
    @time_sheet.update(justification_status: status)

    return_path = determine_return_path
    redirect_to return_path, notice: "Justificativa #{status}."
  end

  def approve_with_justification
    time_sheet_ids = params[:time_sheet_ids]

    TimeSheet.where(id: time_sheet_ids).update_all(
      approval_status: 'aprovado',
      justification_status: 'aprovada',
      approved_by: current_user.id,
      approved_at: Time.current
    )

    redirect_to time_sheets_path, notice: 'Registros aprovados com sucesso.'
  end

  def pending_justifications
    # Apenas disponível para gestores/administradores
    if current_user.role != 'admin' && current_user.role != 'gestor'
      redirect_to time_sheets_path, alert: 'Acesso não autorizado.'
      return
    end

    @pending_sheets = TimeSheet.joins(:user)
                               .where(justification_status: 'pendente')
                               .includes(:time_entries)
                               .order(date: :desc)
                               .page(params[:page])
                               .per(10)
  end

  private

  def time_sheet_params
    params.require(:time_sheet).permit(:date, :status, :approval_status, :justification, :justification_status)
  end

  def set_time_sheet
    @time_sheet = current_user.time_sheets.find(params[:id])
  end


  def determine_return_path
    return_to = params[:return_to]

    if return_to == "calendar"
      calendar_time_sheets_path
    else
      time_sheets_path
    end
  end

  def check_not_approved
    if @time_sheet.approval_status == 'aprovado'
      redirect_to time_sheets_path, alert: 'Não é possível editar um registro aprovado.'
      return false
    end
    true
  end

  def generate_csv(time_sheets)
    headers = ['Data', 'Entrada 1', 'Saída 1', 'Entrada 2', 'Saída 2', 'Total de Horas', 'Status']

    CSV.generate(headers: true) do |csv|
      csv << headers

      time_sheets.each do |sheet|
        entries = sheet.time_entries.order(:time)
        times = entries.map { |e| e.time.strftime("%H:%M") }

        while times.length < 4
          times << "-"
        end

        csv << [
          sheet.date.strftime("%d/%m/%Y"),
          times[0],
          times[1],
          times[2],
          times[3],
          "#{sheet.total_hours}h",
          sheet.approval_status
        ]
      end
    end
  end
end
