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
      'bg-yellow-100 text-yellow-800'
    when 'aprovado'
      'bg-green-100 text-green-800'
    when 'rejeitado'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end