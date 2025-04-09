class TimeSheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_sheet, only: [:show, :approve, :submit_for_approval, :sign]

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
    # Determinar o mês e ano a ser exibido (padrão: mês atual)
    @date = if params[:month] && params[:year]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.today.beginning_of_month
            end

    # Buscar registros de ponto para o mês selecionado
    @time_sheets = current_user.time_sheets
                               .where(date: @date.beginning_of_month..@date.end_of_month)
                               .includes(:time_entries)

    # Mapear registros por data para fácil acesso na view
    @time_sheets_by_date = @time_sheets.index_by(&:date)

    # Criar array de dias para o calendário (incluindo dias do mês anterior/seguinte para completar semanas)
    first_day = @date.beginning_of_month.beginning_of_week(:sunday)
    last_day = @date.end_of_month.end_of_week(:sunday)
    @calendar_days = (first_day..last_day).to_a
  end

  def export
    @time_sheets = current_user.time_sheets
                               .where(date: params[:start_date]..params[:end_date])
                               .includes(:time_entries)
                               .order(:date)

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@time_sheets),
                  filename: "ponto-#{current_user.name.parameterize}-#{Date.today}.csv"
      end
    end
  end

  def submit_for_approval
    @time_sheet.update(approval_status: 'enviado')
    redirect_to time_sheets_path, notice: 'Registro enviado para aprovação.'
  end

  def sign
    @time_sheet.update(signature: true)
    redirect_to time_sheet_path(@time_sheet), notice: 'Registro assinado digitalmente.'
  end

  private

  def set_time_sheet
    @time_sheet = current_user.time_sheets.find(params[:id])
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
