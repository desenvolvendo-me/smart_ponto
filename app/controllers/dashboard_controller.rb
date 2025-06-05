class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.current
    @time_sheet = current_user.time_sheets.find_by(date: @today)
    @daily_summary = calculate_daily_summary
    @weekly_summary = calculate_weekly_summary
    @recent_time_sheets = current_user.time_sheets
                                     .includes(:time_entries)
                                     .order(date: :desc)
                                     .limit(5)

    # Adicionar informações sobre pendências
    if current_user.role == 'gestor'
      # Para gestores, mostrar quantidade de registros aguardando aprovação
      @pending_approvals_count = TimeSheet.where(approval_status: ['enviado', 'pendente']).count
      @pending_enviado_count = TimeSheet.where(approval_status: 'enviado').count
      @pending_pendente_count = TimeSheet.where(approval_status: 'pendente').count

      # Buscar funcionários com registros pendentes
      @employees_with_pending = User.joins(:time_sheets)
                                   .where(time_sheets: { approval_status: ['enviado', 'pendente'] })
                                   .distinct
                                   .order(:name)

      # Buscar os registros pendentes para cada funcionário (limitado a 5 por funcionário)
      @pending_by_employee = {}
      @pending_count_by_employee = {}
      @employees_with_pending.each do |employee|
        # Obter o total de pendências para este funcionário
        @pending_count_by_employee[employee.id] = employee.time_sheets
                                                        .where(approval_status: ['enviado', 'pendente'])
                                                        .count

        # Obter apenas os 5 registros mais recentes para exibição
        @pending_by_employee[employee.id] = employee.time_sheets
                                                  .where(approval_status: ['enviado', 'pendente'])
                                                  .order(date: :desc)
                                                  .limit(5)
      end
    else
      # Para funcionários comuns, mostrar apenas as solicitações que necessitam de ação
      # Excluir solicitações que já foram aprovadas ou rejeitadas (histórico de aprovação)
      @pending_items = current_user.time_sheets
                                  .where(approval_status: 'pendente')
                                  .or(current_user.time_sheets.where(approval_status: 'enviado'))
                                  .order(date: :desc)
      @pending_count = @pending_items.count

      # Contagem por tipo de pendência para funcionários
      @pending_pendente_count = @pending_items.where(approval_status: 'pendente').count
      @pending_enviado_count = @pending_items.where(approval_status: 'enviado').count
    end
  end

  private

  def calculate_daily_summary
    return default_summary unless @time_sheet

    entries = @time_sheet.time_entries.order(:time)

    worked_hours = calculate_worked_hours(entries)
    daily_goal = 8.0

    status = case @time_sheet.approval_status
             when 'aprovado'
               worked_hours >= daily_goal ? 'complete' : 'incomplete'
             when 'enviado'
               'incomplete'
             when 'rejeitado'
               'incomplete'
             when 'pendente'
               worked_hours >= daily_goal ? 'complete' : 'incomplete'
             else
               worked_hours >= daily_goal ? 'complete' : 'incomplete'
             end

    {
      worked_hours: worked_hours,
      daily_goal: daily_goal,
      status: status,
      entries: entries,
      approval_status: @time_sheet.approval_status,
      time_sheet_status: @time_sheet.status
    }
  end

  def calculate_weekly_summary
    start_of_week = @today.beginning_of_week(:monday)
    end_of_week = @today.end_of_week(:monday)

    # Busca todos os time_sheets da semana atual
    weekly_time_sheets = current_user.time_sheets
                                     .where(date: start_of_week..end_of_week)
                                     .includes(:time_entries)

    total_worked_hours = 0
    days_worked = 0

    weekly_time_sheets.each do |time_sheet|
      entries = time_sheet.time_entries.order(:time)
      daily_hours = calculate_worked_hours(entries)

      if daily_hours > 0
        total_worked_hours += daily_hours
        days_worked += 1
      end
    end

    weekly_goal = 40.0
    completion_percentage = (total_worked_hours / weekly_goal * 100).round(1)

    status = if total_worked_hours >= weekly_goal
               'complete'
             elsif total_worked_hours >= (weekly_goal * 0.8)
               'on_track'
             else
               'behind'
             end

    {
      worked_hours: total_worked_hours.round(2),
      weekly_goal: weekly_goal,
      days_worked: days_worked,
      completion_percentage: completion_percentage,
      status: status,
      start_date: start_of_week,
      end_date: end_of_week
    }
  end

  def calculate_worked_hours(entries)
    return 0 if entries.empty?

    total_minutes = 0

    clock_ins = []
    clock_outs = []

    entries.each do |entry|
      case entry.entry_type
      when 'entrada', 'clock_in', 'break_end', 'fim_intervalo'
        clock_ins << entry.time
      when 'saída', 'clock_out', 'break_start', 'inicio_intervalo'
        clock_outs << entry.time
      end
    end

    [clock_ins.length, clock_outs.length].min.times do |i|
      start_time = clock_ins[i]
      end_time = clock_outs[i]

      minutes = calculate_time_diff_minutes(start_time, end_time)
      total_minutes += minutes
    end

    worked_hours = (total_minutes / 60.0).round(2)

    worked_hours
  end

  def calculate_time_diff_minutes(start_time, end_time)
    begin
      if start_time.respond_to?(:hour) && end_time.respond_to?(:hour)
        start_mins = start_time.hour * 60 + start_time.min
        end_mins = end_time.hour * 60 + end_time.min

        end_mins += 24 * 60 if end_mins < start_mins

        return end_mins - start_mins
      elsif start_time.is_a?(String) && end_time.is_a?(String)
        start_parts = start_time.split(':').map(&:to_i)
        end_parts = end_time.split(':').map(&:to_i)

        start_mins = start_parts[0] * 60 + start_parts[1]
        end_mins = end_parts[0] * 60 + end_parts[1]

        end_mins += 24 * 60 if end_mins < start_mins

        return end_mins - start_mins
      else
        start_t = Time.parse(start_time.to_s)
        end_t = Time.parse(end_time.to_s)

        ((end_t - start_t) / 60).round
      end
    rescue => e
      Rails.logger.error "Error calculating time difference: #{e.message}"
      0
    end
  end

  def time_to_seconds(time_str)
    time_str = time_str.strftime("%H:%M:%S") if time_str.respond_to?(:strftime)
    parts = time_str.split(':').map(&:to_i)
    parts[0] * 3600 + parts[1] * 60 + parts[2]
  end

  def default_summary
    {
      worked_hours: 0,
      daily_goal: 8.0,
      status: 'incomplete',
      entries: [],
      approval_status: nil,
      time_sheet_status: nil
    }
  end
end
