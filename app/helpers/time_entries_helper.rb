module TimeEntriesHelper
  # Verifica se usuário pode registrar na data
  def can_register_on_date?(user, date)
    return true unless date.saturday? || date.sunday?
    user.can_register_on_weekend?
  end

  # Tooltip para registro bloqueado
  def weekend_registration_tooltip
    "Não liberado registrar ponto no fim de semana"
  end

  # Classes CSS para botão baseado em permissão
  def registration_button_classes(user, date, base_classes = "")
    if can_register_on_date?(user, date)
      base_classes
    else
      "#{base_classes} opacity-50 cursor-not-allowed pointer-events-none"
    end
  end
end
