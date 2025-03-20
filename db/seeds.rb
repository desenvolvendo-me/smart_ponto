# db/seeds.rb

# Limpar registros existentes
puts "Apagando registros existentes..."
TimeEntry.destroy_all
TimeSheet.destroy_all
User.destroy_all

# Criar usuário de teste
puts "Criando usuário de teste..."
user = User.create!(
  email: 'funcionario@exemplo.com',
  password: 'senha123',
  name: 'João Silva',
  department: 'TI',
  role: 'Desenvolvedor',
  employee_id: 'F001',
  position: 'Desenvolvedor Full Stack',
  start_date: Date.new(2023, 1, 15),
  status: 'ativo'
)

# Criar registros para todo o mês corrente
puts "Criando registros para o mês corrente..."
current_month = Date.today.beginning_of_month
end_of_month = Date.today.end_of_month
date_range = (current_month..end_of_month).to_a

# Horários padrão
standard_times = {
  morning_in: '08:00',
  morning_out: '12:00',
  afternoon_in: '13:00',
  afternoon_out: '17:00'
}

# Criar registros para dias úteis (seg-sex)
date_range.each do |date|
  # Pular sábados e domingos
  next if date.saturday? || date.sunday?

  # Para datas passadas
  if date < Date.today
    # Determinar status aleatório (maioria aprovados, alguns completos, poucos pendentes)
    status_rand = rand(10)
    if status_rand < 7
      approval_status = 'aprovado'
      entry_status = 'aprovado'
    elsif status_rand < 9
      approval_status = 'enviado'
      entry_status = 'registrado'
    else
      approval_status = 'pendente'
      entry_status = 'registrado'
    end

    # Variação nas horas (ocasionalmente)
    time_variation = rand(10)
    if time_variation == 0
      # Atraso na entrada da manhã
      morning_in_time = (Time.parse(standard_times[:morning_in]) + rand(5..30).minutes).strftime("%H:%M")
      observation = "Atraso devido a consulta médica"
    elsif time_variation == 1
      # Saída tardia
      afternoon_out_time = (Time.parse(standard_times[:afternoon_out]) + rand(5..60).minutes).strftime("%H:%M")
      observation = "Hora extra para finalizar projeto"
    else
      morning_in_time = standard_times[:morning_in]
      afternoon_out_time = standard_times[:afternoon_out]
      observation = nil
    end

    # Criar time_sheet primeiro
    time_sheet = TimeSheet.create!(
      user: user,
      date: date,
      status: 'completo',
      approval_status: approval_status,
      signature: approval_status == 'aprovado' || approval_status == 'enviado',
      approved_by: approval_status == 'aprovado' ? 1 : nil,
      approved_at: approval_status == 'aprovado' ? date + 1.day : nil
    )

    # Criar entradas de ponto
    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: morning_in_time || standard_times[:morning_in],
      entry_type: 'entrada',
      status: entry_status,
      observation: observation
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: standard_times[:morning_out],
      entry_type: 'saída',
      status: entry_status
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: standard_times[:afternoon_in],
      entry_type: 'entrada',
      status: entry_status
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: afternoon_out_time || standard_times[:afternoon_out],
      entry_type: 'saída',
      status: entry_status
    )

  # Para o dia atual
  elsif date == Date.today
    time_sheet = TimeSheet.create!(
      user: user,
      date: date,
      status: 'completo',
      approval_status: 'pendente',
      signature: false
    )

    # Criar entradas para o dia atual (todas já registradas)
    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: '08:15',
      entry_type: 'entrada',
      status: 'registrado'
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: '12:00',
      entry_type: 'saída',
      status: 'registrado'
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: '13:00',
      entry_type: 'entrada',
      status: 'registrado'
    )

    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet,
      date: date,
      time: '17:00',
      entry_type: 'saída',
      status: 'registrado'
    )
  end
end

# Criar alguns registros com observações especiais
special_dates = date_range.select { |d| !d.saturday? && !d.sunday? && d < Date.today }.sample(3)

special_observations = [
  "Atraso devido a problemas no transporte público",
  "Consulta médica no período da tarde",
  "Saída antecipada para reunião externa"
]

special_dates.each_with_index do |date, index|
  time_sheet = TimeSheet.find_by(date: date, user: user)

  if time_sheet
    entries = time_sheet.time_entries.order(:time)
    if entries.any?
      entry = entries.first
      entry.update(observation: special_observations[index])
    end
  end
end

# Adicionar um administrador para aprovações
admin = User.create!(
  email: 'gerente@exemplo.com',
  password: 'senha123',
  name: 'Carlos Gerente',
  department: 'Administração',
  role: 'Gerente',
  employee_id: 'G001',
  position: 'Gerente de Departamento',
  start_date: Date.new(2020, 1, 1),
  status: 'ativo'
)

puts "Seeds concluídos com sucesso!"
puts "----------------------------------------"
puts "Usuário funcionário criado:"
puts "- Email: funcionario@exemplo.com"
puts "- Senha: senha123"
puts ""
puts "Usuário gerente criado:"
puts "- Email: gerente@exemplo.com"
puts "- Senha: senha123"
puts "----------------------------------------"
puts "Total de registros criados:"
puts "- Usuários: #{User.count}"
puts "- Folhas de ponto: #{TimeSheet.count}"
puts "- Entradas de ponto: #{TimeEntry.count}"
