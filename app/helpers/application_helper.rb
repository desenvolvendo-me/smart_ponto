module ApplicationHelper
  def format_hours_minutes(decimal_hours)
    hours = decimal_hours.to_i
    minutes = ((decimal_hours - hours) * 60).round
    "#{hours}h #{'%02d' % minutes}min"
  end

  def format_entry_type(entry_type)
    case entry_type
    when 'clock_in' then 'Entrada'
    when 'clock_out' then 'Saída'
    when 'break_start' then 'Início Intervalo'
    when 'break_end' then 'Fim Intervalo'
    else entry_type.humanize
    end
  end
end