module TimeSheetsHelper
  def format_hours(decimal_hours)
    # Verificar se é nil ou zero
    return "0h 00min" if decimal_hours.nil? || decimal_hours.to_s.strip == "0" || decimal_hours == 0

    begin
      # Garantir que estamos trabalhando com um número
      decimal_hours = Float(decimal_hours.to_s.strip)

      hours = decimal_hours.to_i
      # Arredondamento para evitar problemas de precisão com números flutuantes
      minutes = ((decimal_hours - hours) * 60).round

      # Lidar com o caso em que os minutos arredondam para 60
      if minutes == 60
        hours += 1
        minutes = 0
      end

      "#{hours}h #{minutes.to_s.rjust(2, '0')}min"
    rescue ArgumentError, TypeError
      # Se não conseguirmos converter para número, retornar um valor padrão
      "0h 00min"
    end
  end

  def time_sheet_status_meta(time_sheet)
    if time_sheet.approval_status == "aprovado"
      {
        label: "Aprovado",
        icon: "fa-check-circle",
        classes: "border border-green-200 bg-green-50 text-green-700"
      }
    elsif time_sheet.approval_status == "enviado"
      {
        label: "Enviado para aprovação",
        icon: "fa-paper-plane",
        classes: "border border-blue-200 bg-blue-50 text-blue-700"
      }
    elsif time_sheet.approval_status == "rejeitado"
      {
        label: "Rejeitado",
        icon: "fa-times-circle",
        classes: "border border-red-200 bg-red-50 text-red-700"
      }
    elsif time_sheet.status == "completo"
      {
        label: "Completo",
        icon: "fa-check",
        classes: "border border-indigo-200 bg-indigo-50 text-indigo-700"
      }
    else
      {
        label: "Incompleto",
        icon: "fa-exclamation-circle",
        classes: "border border-amber-200 bg-amber-50 text-amber-700"
      }
    end
  end

  def time_sheet_relative_day_label(date)
    return ["Hoje", "bg-indigo-100 text-indigo-700"] if date.today?
    return ["Ontem", "bg-muted text-muted-foreground"] if (Date.current - date).to_i == 1

    nil
  end

  def time_sheet_total_meta(time_sheet)
    hours = time_sheet.total_hours.to_f
    difference_minutes = ((hours - 8.0).abs * 60).round

    if time_sheet.within_tolerance?
      {
        tone: "text-green-700",
        badge: "Tolerância OK",
        badge_classes: "bg-green-100 text-green-700",
        hint: "Jornada dentro da tolerância de 15 minutos."
      }
    else
      {
        tone: "text-amber-700",
        badge: "Diferença: #{difference_minutes}min",
        badge_classes: "bg-amber-100 text-amber-700",
        hint: "Fora da tolerância de 15 minutos."
      }
    end
  end

  def time_sheet_day_meta(time_sheet)
    if time_sheet.approval_status == "rejeitado"
      {
        attention: true,
        resolved: false,
        card_classes: "border-red-200 bg-red-50/35",
        summary_classes: "border-red-200 bg-white",
        guidance_classes: "border-red-200 bg-red-50 text-red-800",
        guidance_label: "Ação necessária",
        guidance_text: "Este dia foi rejeitado. Revise a justificativa e ajuste antes de reenviar."
      }
    elsif time_sheet.status == "completo" && !time_sheet.within_tolerance? && time_sheet.justification.blank?
      {
        attention: true,
        resolved: false,
        card_classes: "border-amber-200 bg-amber-50/35",
        summary_classes: "border-amber-200 bg-white",
        guidance_classes: "border-amber-200 bg-amber-50 text-amber-800",
        guidance_label: "Justificativa obrigatória",
        guidance_text: "A diferença de horas exige justificativa antes do envio para aprovação."
      }
    elsif time_sheet.justification_status == "pendente"
      {
        attention: true,
        resolved: false,
        card_classes: "border-blue-200 bg-blue-50/30",
        summary_classes: "border-blue-200 bg-white",
        guidance_classes: "border-blue-200 bg-blue-50 text-blue-800",
        guidance_label: "Em análise",
        guidance_text: "A justificativa foi enviada e está aguardando revisão."
      }
    elsif time_sheet.approval_status == "aprovado"
      {
        attention: false,
        resolved: true,
        card_classes: "border-white/80 bg-white/88",
        summary_classes: "border-green-200 bg-green-50/50",
        guidance_classes: "border-green-200 bg-green-50 text-green-800",
        guidance_label: "Dia concluído",
        guidance_text: "Jornada aprovada e sem ações pendentes."
      }
    elsif time_sheet.approval_status == "enviado"
      {
        attention: false,
        resolved: true,
        card_classes: "border-white/80 bg-white/90",
        summary_classes: "border-blue-200 bg-blue-50/40",
        guidance_classes: "border-blue-200 bg-blue-50 text-blue-800",
        guidance_label: "Aguardando aprovação",
        guidance_text: "Registro enviado. Aguarde a revisão do gestor."
      }
    else
      {
        attention: false,
        resolved: false,
        card_classes: "border-white/80 bg-white/92",
        summary_classes: "border-border/70 bg-secondary/20",
        guidance_classes: "border-border/70 bg-secondary/20 text-secondary-foreground",
        guidance_label: "Em andamento",
        guidance_text: "Confira os horários do dia e conclua o que ainda estiver pendente."
      }
    end
  end

  def time_sheet_next_step_meta(time_sheet)
    if time_sheet.approval_status == "aprovado"
      {
        title: "Dia concluído",
        description: "Nada pendente neste registro."
      }
    elsif time_sheet.approval_status == "enviado"
      {
        title: "Aguardando aprovação",
        description: "Seu registro já foi enviado para revisão."
      }
    elsif time_sheet.status == "completo" && time_sheet.justification.present?
      {
        title: "Pronto para revisão",
        description: "Registro completo e com justificativa pronta para análise."
      }
    elsif time_sheet.status == "completo" && time_sheet.within_tolerance?
      {
        title: "Pronto para envio",
        description: "Registro completo e dentro da tolerância."
      }
    elsif time_sheet.status == "completo"
      {
        title: "Justificativa necessária",
        description: "Adicione uma justificativa antes de enviar este dia."
      }
    else
      {
        title: "Complete os horários",
        description: "Conclua os registros pendentes para avançar."
      }
    end
  end

  def time_sheet_justification_meta(time_sheet)
    return nil unless time_sheet.justification.present?

    case time_sheet.justification_status
    when "aprovada"
      {
        label: "Justificativa aprovada",
        classes: "border border-green-200 bg-green-50 text-green-700",
        icon: "fa-check-circle"
      }
    when "rejeitada"
      {
        label: "Justificativa rejeitada",
        classes: "border border-red-200 bg-red-50 text-red-700",
        icon: "fa-times-circle"
      }
    when "pendente"
      {
        label: "Justificativa pendente",
        classes: "border border-amber-200 bg-amber-50 text-amber-700",
        icon: "fa-clock"
      }
    else
      {
        label: "Justificativa registrada",
        classes: "border border-border bg-muted text-muted-foreground",
        icon: "fa-comment-alt"
      }
    end
  end

  def time_sheet_entry_meta(entry)
    if entry.entry_type == "entrada"
      {
        label: "Entrada",
        icon: "fa-sign-in-alt",
        icon_classes: "text-green-600"
      }
    else
      {
        label: "Saída",
        icon: "fa-sign-out-alt",
        icon_classes: "text-red-600"
      }
    end
  end

  def time_sheet_entry_status_meta(entry)
    if entry.status == "aprovado"
      {
        label: "Aprovado",
        icon: "fa-check-circle",
        classes: "bg-green-50 text-green-700"
      }
    else
      {
        label: "Registrado",
        icon: "fa-clock",
        classes: "bg-muted text-muted-foreground"
      }
    end
  end

  def calendar_day_meta(day, reference_month, time_sheet = nil)
    in_month = day.month == reference_month.month
    today = day == Date.current
    weekend = day.saturday? || day.sunday?
    status = time_sheet_status_meta(time_sheet) if time_sheet

    base_classes = if !in_month
      "bg-white/45 text-muted-foreground/60"
    elsif time_sheet&.approval_status == "rejeitado"
      "bg-red-50/60 ring-1 ring-red-200"
    elsif time_sheet&.justification_status == "pendente"
      "bg-blue-50/60 ring-1 ring-blue-200"
    elsif time_sheet && !time_sheet.within_tolerance?
      "bg-amber-50/60 ring-1 ring-amber-200"
    elsif time_sheet&.approval_status == "aprovado"
      "bg-green-50/45 ring-1 ring-green-200"
    elsif time_sheet&.approval_status == "enviado"
      "bg-blue-50/45 ring-1 ring-blue-200"
    elsif today
      "bg-indigo-50 ring-2 ring-indigo-500 ring-inset"
    elsif weekend
      "bg-secondary/20"
    else
      "bg-white"
    end

    accent_classes = if time_sheet&.approval_status == "rejeitado"
      "bg-red-500"
    elsif time_sheet&.justification_status == "pendente"
      "bg-blue-500"
    elsif time_sheet && !time_sheet.within_tolerance?
      "bg-amber-500"
    elsif time_sheet&.approval_status == "aprovado"
      "bg-green-500"
    elsif time_sheet&.approval_status == "enviado"
      "bg-blue-500"
    elsif time_sheet
      "bg-indigo-500"
    else
      nil
    end

    {
      in_month:,
      today:,
      weekend:,
      base_classes:,
      accent_classes:,
      day_number_classes: [
        "text-lg font-semibold",
        (!in_month ? "text-muted-foreground/50" : "text-foreground"),
        (weekend && in_month ? "text-red-600" : nil),
        (today ? "text-indigo-700" : nil)
      ].compact.join(" "),
      status:,
      total_hours: time_sheet ? format_hours(time_sheet.total_hours) : nil,
      empty_past_day: in_month && day < Date.current && time_sheet.blank?,
      empty_today: in_month && day == Date.current && time_sheet.blank?
    }
  end

  def calendar_entry_pair(time_sheet)
    return [] unless time_sheet

    time_sheet.time_entries.order(:time).each_slice(2).map do |entry_pair|
      {
        entry: entry_pair[0]&.time&.strftime("%H:%M") || "--:--",
        exit: entry_pair[1]&.time&.strftime("%H:%M") || "--:--"
      }
    end
  end

  def calendar_month_summary(time_sheets, date)
    total_days = time_sheets.count
    total_hours = time_sheets.sum { |ts| ts.total_hours.to_f }
    pending_count = time_sheets.count { |ts| ts.approval_status == "pendente" }
    approved_count = time_sheets.count { |ts| ts.approval_status == "aprovado" }
    sent_count = time_sheets.count { |ts| ts.approval_status == "enviado" }
    rejected_count = time_sheets.count { |ts| ts.approval_status == "rejeitado" }

    business_days = (date.beginning_of_month..date.end_of_month).count { |day| !day.saturday? && !day.sunday? }
    completion_percentage = if business_days.positive?
      [(total_days.to_f / business_days * 100).round, 100].min
    else
      0
    end

    {
      total_days:,
      total_hours: total_hours.round(1),
      pending_count:,
      approved_count:,
      sent_count:,
      rejected_count:,
      business_days:,
      completion_percentage:
    }
  end
end
