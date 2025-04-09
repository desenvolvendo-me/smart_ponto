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
end