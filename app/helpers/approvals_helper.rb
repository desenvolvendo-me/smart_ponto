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
      'bg-yellow-500 text-white shadow-sm'
    when 'aprovado'
      'bg-green-500 text-white shadow-sm'
    when 'rejeitado'
      'bg-red-500 text-white shadow-sm'
    else
      'bg-gray-500 text-white shadow-sm'
    end
  end
end
