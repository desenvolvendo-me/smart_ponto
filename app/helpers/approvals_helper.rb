module ApprovalsHelper
  def determine_request_type(time_sheet)
    if time_sheet.justification&.include?('Horas Extras')
      'Horas Extras'
    elsif time_sheet.justification&.include?('Ajuste')
      'Ajuste de Horário'
    elsif time_sheet.total_hours.to_f > 8.0
      'Horas Extras'
    else
      'Ajuste de Horário'
    end
  end

  def status_badge_class(status)
    case status
    when 'enviado', 'pendente'
      'border border-amber-200 bg-amber-50 text-amber-700'
    when 'aprovado'
      'border border-green-200 bg-green-50 text-green-700'
    when 'rejeitado'
      'border border-red-200 bg-red-50 text-red-700'
    else
      'border border-border bg-muted text-muted-foreground'
    end
  end
end
