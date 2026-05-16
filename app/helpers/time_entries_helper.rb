module TimeEntriesHelper
  # Verifica se usuário pode registrar na data
  def can_register_on_date?(user, date)
    user.can_register_on_date?(date)
  end

  def weekend_registration_tooltip(user, date)
    return unless date.saturday? || date.sunday?

    if user.gestor?
      "Como gestor, a regra de bloqueio de fim de semana não se aplica ao seu perfil."
    elsif !can_register_on_date?(user, date)
      "Não liberado registrar ponto no fim de semana. Liberação automática somente para gestor."
    end
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
