module DashboardHelper
  def dashboard_daily_status_meta(summary)
    case summary[:approval_status]
    when "aprovado"
      {
        label: "Ponto aprovado",
        icon: "fa-check-circle",
        classes: "border border-green-200 bg-green-50 text-green-700",
        description: "Sua jornada de hoje já foi validada."
      }
    when "enviado"
      {
        label: "Em revisão",
        icon: "fa-paper-plane",
        classes: "border border-blue-200 bg-blue-50 text-blue-700",
        description: "O registro foi enviado para aprovação."
      }
    when "rejeitado"
      {
        label: "Requer ajuste",
        icon: "fa-times-circle",
        classes: "border border-red-200 bg-red-50 text-red-700",
        description: "Revise a justificativa e envie novamente."
      }
    when "pendente"
      if summary[:status] == "complete"
        {
          label: "Pronto para envio",
          icon: "fa-check",
          classes: "border border-indigo-200 bg-indigo-50 text-indigo-700",
          description: "Seu dia está completo e pode seguir para aprovação."
        }
      else
        {
          label: "Dia em andamento",
          icon: "fa-hourglass-half",
          classes: "border border-amber-200 bg-amber-50 text-amber-700",
          description: "Ainda faltam registros para fechar o dia."
        }
      end
    else
      {
        label: "Sem registros hoje",
        icon: "fa-clock",
        classes: "border border-border bg-secondary/30 text-secondary-foreground",
        description: "Registre seu primeiro horário para acompanhar o dia."
      }
    end
  end

  def dashboard_weekly_status_meta(summary)
    if summary[:status] == "complete"
      {
        label: "Meta atingida",
        icon: "fa-trophy",
        classes: "border border-green-200 bg-green-50 text-green-700",
        tone: "text-green-700"
      }
    elsif summary[:status] == "on_track"
      {
        label: "No ritmo esperado",
        icon: "fa-chart-line",
        classes: "border border-indigo-200 bg-indigo-50 text-indigo-700",
        tone: "text-indigo-700"
      }
    else
      {
        label: "Abaixo da meta",
        icon: "fa-exclamation-triangle",
        classes: "border border-amber-200 bg-amber-50 text-amber-700",
        tone: "text-amber-700"
      }
    end
  end

  def dashboard_pending_item_meta(time_sheet)
    status = time_sheet.approval_status == "enviado" ? "Enviado" : "Pendente"
    status_classes = time_sheet.approval_status == "enviado" ? "bg-blue-100 text-blue-700" : "bg-amber-100 text-amber-700"

    alerts = []
    alerts << { label: status, classes: status_classes }
    alerts << { label: "Horas extras", classes: "bg-violet-100 text-violet-700" } if time_sheet.total_hours.to_f > 8.0
    alerts << { label: "Ajuste", classes: "bg-orange-100 text-orange-700" } unless time_sheet.within_tolerance?

    {
      alerts: alerts,
      total: format_hours(time_sheet.total_hours),
      justification: time_sheet.justification.present? ? truncate(time_sheet.justification, length: 72) : nil
    }
  end

  def dashboard_entry_meta(entry)
    icon = case entry.entry_type
    when "entrada", "clock_in"
      "fa-sign-in-alt"
    when "saída", "clock_out"
      "fa-sign-out-alt"
    when "break_start", "inicio_intervalo"
      "fa-mug-hot"
    when "break_end", "fim_intervalo"
      "fa-person-walking"
    else
      "fa-clock"
    end

    {
      icon: icon,
      label: format_entry_type(entry.entry_type)
    }
  end

  def dashboard_recent_time_sheet_meta(time_sheet)
    status = time_sheet_status_meta(time_sheet)
    next_step = time_sheet_next_step_meta(time_sheet)
    total = time_sheet_total_meta(time_sheet)
    justification = time_sheet_justification_meta(time_sheet)
    attention = time_sheet.approval_status == "rejeitado" ||
                time_sheet.justification_status == "pendente" ||
                (!time_sheet.within_tolerance? && time_sheet.approval_status != "aprovado")

    {
      status: status,
      next_step: next_step,
      total: total,
      justification: justification,
      attention: attention,
      card_classes: if attention
                      "border-amber-200 bg-amber-50/40"
                    else
                      "border-border/70 bg-secondary/10"
                    end,
      action_label: time_sheet.approval_status == "aprovado" ? "Ver detalhes" : "Abrir dia",
      action_icon: time_sheet.approval_status == "aprovado" ? "fa-eye" : "fa-pen"
    }
  end

  def dashboard_period_label(start_date, end_date)
    "#{l(start_date, format: :short)} - #{l(end_date, format: :short)}"
  end

  def dashboard_has_activity?(summary)
    summary[:entries].any?
  end
end
