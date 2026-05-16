class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_weekend_registration, only: [:new, :create, :quick_register]
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]

  def index
    @time_entries = current_user.time_entries.order(created_at: :desc)
  end

  def show
  end

  def new
    @time_entry = TimeEntry.new
    @time_entry.date = params[:date] || Date.today
    @time_entry.time = Time.current
  end

  def edit
  end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)

    # Verificar se já existe uma folha de ponto para a data
    time_sheet = current_user.time_sheets.find_or_create_by(date: @time_entry.date)
    @time_entry.time_sheet = time_sheet

    respond_to do |format|
      if @time_entry.save
        return_path = determine_return_path

        format.html { redirect_to return_path, notice: 'Registro de ponto criado com sucesso.' }
        format.json { render :show, status: :created, location: @time_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @time_entry.update(time_entry_params)
        return_path = determine_return_path

        format.html { redirect_to return_path, notice: 'Registro de ponto atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @time_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @time_entry.destroy

    respond_to do |format|
      return_path = determine_return_path

      format.html { redirect_to return_path, notice: 'Registro de ponto excluído.' }
      format.json { head :no_content }
    end
  end

  def quick_register
    # Criar registro automático de entrada ou saída
    date = Date.today
    time = Time.current

    # Buscar a folha de ponto para hoje (criar se não existir)
    time_sheet = current_user.time_sheets.find_or_create_by(date: date)

    # Verificar último registro para determinar se é entrada ou saída
    entries = time_sheet.time_entries.order(time: :desc)
    last_entry = entries.first

    # Determinar tipo de entrada baseado na última entrada registrada
    if last_entry.nil? || last_entry.entry_type != "entrada"
      entry_type = "entrada"
    else
      entry_type = "saída"
    end

    # Criar registro usando ActiveRecord (seguro contra SQL injection)
    begin
      new_entry = TimeEntry.create!(
        user_id: current_user.id,
        time_sheet_id: time_sheet.id,
        date: date,
        time: time,
        entry_type: entry_type,
        status: 'registrado'
      )

      update_timesheet_totals(time_sheet)
      return_path = determine_return_path
      redirect_to return_path, notice: "Ponto registrado com sucesso: #{entry_type.capitalize} às #{time.strftime('%H:%M')}"
    rescue ActiveRecord::RecordInvalid => e
      return_path = determine_return_path
      redirect_to return_path, alert: "Não foi possível registrar o ponto. Por favor, tente novamente."
      Rails.logger.error "Failed to create time entry: #{e.message}"
    end
  end

  # Método auxiliar para atualizar totais na folha de ponto
  def update_timesheet_totals(time_sheet)
    # Calcular total de horas
    entries = time_sheet.time_entries.order(:time)

    # Agrupar entradas e saídas
    total_hours = 0
    current_entry = nil

    entries.each do |entry|
      if entry.entry_type == 'entrada'
        current_entry = entry
      elsif entry.entry_type == 'saida' && current_entry.present?
        # Calcular diferença de tempo em horas
        hours = (entry.time - current_entry.time) / 3600.0
        total_hours += hours
        current_entry = nil
      end
    end

    # Atualizar status e total de horas
    status = entries.size >= 2 ? 'completo' : 'incompleto'
    time_sheet.update(total_hours: total_hours.round(2), status: status)
  end

  private
  def set_time_entry
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:date, :time, :entry_type, :observation, :signature)
  end

  def determine_return_path
    return_to = params[:return_to]

    if return_to == "calendar"
      calendar_time_sheets_path
    else
      time_sheets_path
    end
  end

  def validate_weekend_registration
    date_to_check = params[:date]&.to_date || Date.today

    unless current_user.can_register_on_date?(date_to_check)
      flash[:alert] = "Você não tem permissão para registrar ponto em fins de semana. Liberação automática somente para gestor."
      redirect_to determine_return_path || time_sheets_path
      return false
    end

    true
  end
end
