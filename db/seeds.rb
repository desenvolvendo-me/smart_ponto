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

# Cenários para testar a regra de tolerância e justificativas
tolerance_scenarios = {
  within_tolerance: [
    { morning_in: '08:10', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:05' }, # 5 min a mais (dentro da tolerância)
    { morning_in: '08:00', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:10' }, # 10 min a mais (dentro da tolerância)
    { morning_in: '07:55', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00' }, # 5 min a menos (dentro da tolerância)
    { morning_in: '07:50', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00' }, # 10 min a menos (dentro da tolerância)
  ],
  needs_justification: [
    { morning_in: '08:00', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:30', desc: "30 min a mais" }, # 30 min a mais (fora da tolerância)
    { morning_in: '08:30', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00', desc: "30 min a menos" }, # 30 min a menos (fora da tolerância)
    { morning_in: '08:45', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00', desc: "45 min a menos" }, # 45 min a menos (fora da tolerância)
    { morning_in: '08:00', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:45', desc: "45 min a mais" }, # 45 min a mais (fora da tolerância)
  ],
  with_justification: [
    {
      morning_in: '08:30', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00',
      desc: "30 min a menos - com justificativa",
      justification: "Consulta médica no início da manhã",
      justification_status: "aprovada"
    },
    {
      morning_in: '08:00', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:35',
      desc: "35 min a mais - com justificativa",
      justification: "Reunião com cliente estendeu além do horário",
      justification_status: "aprovada"
    },
    {
      morning_in: '08:45', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '17:00',
      desc: "45 min a menos - com justificativa pendente",
      justification: "Problema com transporte público",
      justification_status: "pendente"
    },
    {
      morning_in: '08:00', morning_out: '12:00', afternoon_in: '13:00', afternoon_out: '18:00',
      desc: "1h a mais - com justificativa rejeitada",
      justification: "Trabalhei mais para adiantar o projeto",
      justification_status: "rejeitada"
    }
  ]
}

# Rastreia as datas já usadas para cada usuário para evitar duplicação
used_dates = { user.id => Set.new }

# Criar registros para dias úteis (seg-sex)
date_range.each_with_index do |date, index|
  # Pular sábados e domingos
  next if date.saturday? || date.sunday?
  # Não criar registros para datas futuras
  next if date > Date.today
  # Pular datas já usadas para este usuário
  next if used_dates[user.id].include?(date)

  # Registrar que esta data está sendo usada para este usuário
  used_dates[user.id] << date

  # Determinar o tipo de cenário para esta data
  if index % 12 == 0 # A cada 12 dias úteis, usar um cenário "needs_justification" sem justificativa
    scenario_type = :needs_justification
    scenario_index = (index / 12) % tolerance_scenarios[:needs_justification].length
    scenario = tolerance_scenarios[:needs_justification][scenario_index]
    has_justification = false
    justification = nil
    justification_status = nil
  elsif index % 12 == 4 # A cada 12 dias úteis (começando do 4º), usar um cenário "with_justification"
    scenario_type = :with_justification
    scenario_index = (index / 12) % tolerance_scenarios[:with_justification].length
    scenario = tolerance_scenarios[:with_justification][scenario_index]
    has_justification = true
    justification = scenario[:justification]
    justification_status = scenario[:justification_status]
  else # Nos outros dias, usar cenários "within_tolerance"
    scenario_type = :within_tolerance
    scenario_index = index % tolerance_scenarios[:within_tolerance].length
    scenario = tolerance_scenarios[:within_tolerance][scenario_index]
    has_justification = false
    justification = nil
    justification_status = nil
  end

  # Determinar status com base no tipo de cenário e data
  if date < Date.today - 7 # Registros mais antigos que 7 dias geralmente são aprovados
    if scenario_type == :with_justification
      approval_status = scenario[:justification_status] == "aprovada" ? "aprovado" : "enviado"
      entry_status = scenario[:justification_status] == "aprovada" ? "aprovado" : "registrado"
    elsif scenario_type == :within_tolerance
      # Dentro da tolerância, aprovado automaticamente na maioria dos casos
      approval_status = rand(10) < 8 ? "aprovado" : "enviado"
      entry_status = approval_status == "aprovado" ? "aprovado" : "registrado"
    else
      # Fora da tolerância sem justificativa, geralmente ainda pendente
      approval_status = "pendente"
      entry_status = "registrado"
    end
  elsif date < Date.today - 2 # Entre 2 e 7 dias atrás, status mais variados
    if scenario_type == :with_justification
      approval_status = ["aprovado", "enviado", "pendente"].sample
      entry_status = approval_status == "aprovado" ? "aprovado" : "registrado"
    elsif scenario_type == :within_tolerance
      approval_status = ["aprovado", "enviado"].sample
      entry_status = approval_status == "aprovado" ? "aprovado" : "registrado"
    else
      approval_status = "pendente"
      entry_status = "registrado"
    end
  else # Últimos 2 dias, geralmente pendentes ou enviados
    approval_status = scenario_type == :within_tolerance ? ["enviado", "pendente"].sample : "pendente"
    entry_status = "registrado"
  end

  # Criar time_sheet primeiro
  time_sheet = TimeSheet.create!(
    user: user,
    date: date,
    status: 'completo',
    approval_status: approval_status,
    justification: justification,
    justification_status: justification_status,
    signature: approval_status == 'aprovado' || approval_status == 'enviado',
    approved_by: approval_status == 'aprovado' ? 1 : nil,
    approved_at: approval_status == 'aprovado' ? date + 1.day : nil
  )

  # Criar entradas de ponto para o dia
  TimeEntry.create!(
    user: user,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:morning_in],
    entry_type: 'entrada',
    status: entry_status,
    observation: scenario_type != :within_tolerance ? "Horário alterado: #{scenario[:desc]}" : nil
  )

  TimeEntry.create!(
    user: user,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:morning_out],
    entry_type: 'saída',
    status: entry_status
  )

  TimeEntry.create!(
    user: user,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:afternoon_in],
    entry_type: 'entrada',
    status: entry_status
  )

  TimeEntry.create!(
    user: user,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:afternoon_out],
    entry_type: 'saída',
    status: entry_status
  )
end

# Adicionar um administrador para aprovações
admin = User.create!(
  email: 'gerente@exemplo.com',
  password: 'senha123',
  name: 'Carlos Gerente',
  department: 'Administração',
  role: 'gestor',  # Alterado para "gestor" para funcionar com a lógica de permissões
  employee_id: 'G001',
  position: 'Gerente de Departamento',
  start_date: Date.new(2020, 1, 1),
  status: 'ativo'
)

# Adicionar outro funcionário com padrões variados
puts "Criando funcionário adicional..."
user2 = User.create!(
  email: 'maria@exemplo.com',
  password: 'senha123',
  name: 'Maria Oliveira',
  department: 'Marketing',
  role: 'Analista',
  employee_id: 'F002',
  position: 'Analista de Marketing',
  start_date: Date.new(2024, 1, 5),
  status: 'ativo'
)

# Inicializar o conjunto de datas usadas para o segundo usuário
used_dates[user2.id] = Set.new

# Criar alguns registros para o segundo funcionário (últimos 10 dias úteis)
last_10_workdays = date_range.select { |d| !d.saturday? && !d.sunday? && d <= Date.today }.last(10)

last_10_workdays.each_with_index do |date, index|
  # Pular datas já usadas para este usuário
  next if used_dates[user2.id].include?(date)

  # Registrar que esta data está sendo usada para este usuário
  used_dates[user2.id] << date

  # Alternar entre cenários
  if index % 3 == 0
    # A cada 3 dias, criar um registro que precisa de justificativa
    scenario = tolerance_scenarios[:needs_justification][index % tolerance_scenarios[:needs_justification].length]
    has_justification = false
    justification = nil
    justification_status = nil
    approval_status = "pendente"
  elsif index % 3 == 1
    # Um dia após, criar um registro com justificativa
    scenario = tolerance_scenarios[:with_justification][index % tolerance_scenarios[:with_justification].length]
    has_justification = true
    justification = scenario[:justification]
    justification_status = scenario[:justification_status]
    approval_status = justification_status == "aprovada" ? "aprovado" :
                        justification_status == "pendente" ? "enviado" : "pendente"
  else
    # Outros dias, dentro da tolerância
    scenario = tolerance_scenarios[:within_tolerance][index % tolerance_scenarios[:within_tolerance].length]
    has_justification = false
    justification = nil
    justification_status = nil
    approval_status = ["aprovado", "enviado"].sample
  end

  entry_status = approval_status == "aprovado" ? "aprovado" : "registrado"

  # Criar time_sheet
  time_sheet = TimeSheet.create!(
    user: user2,
    date: date,
    status: 'completo',
    approval_status: approval_status,
    justification: justification,
    justification_status: justification_status,
    signature: approval_status == 'aprovado' || approval_status == 'enviado',
    approved_by: approval_status == 'aprovado' ? 1 : nil,
    approved_at: approval_status == 'aprovado' ? date + 1.day : nil
  )

  # Criar entradas de ponto
  TimeEntry.create!(
    user: user2,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:morning_in],
    entry_type: 'entrada',
    status: entry_status
  )

  TimeEntry.create!(
    user: user2,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:morning_out],
    entry_type: 'saída',
    status: entry_status
  )

  TimeEntry.create!(
    user: user2,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:afternoon_in],
    entry_type: 'entrada',
    status: entry_status
  )

  TimeEntry.create!(
    user: user2,
    time_sheet: time_sheet,
    date: date,
    time: scenario[:afternoon_out],
    entry_type: 'saída',
    status: entry_status
  )
end

# Criar registros para o dia atual (sem todas as entradas) apenas se não existirem
if Date.today.on_weekday? && !used_dates[user.id].include?(Date.today)
  # Registrar que esta data está sendo usada para este usuário
  used_dates[user.id] << Date.today

  # Para o primeiro usuário, criar time_sheet sem todas as entradas (incompleto)
  time_sheet_today = TimeSheet.create!(
    user: user,
    date: Date.today,
    status: 'incompleto',
    approval_status: 'pendente'
  )

  # Apenas 2-3 registros para o dia atual
  entries_today = [
    { time: '08:05', entry_type: 'entrada' },
    { time: '12:00', entry_type: 'saída' }
  ]

  # Adicionar uma terceira entrada em alguns casos
  if rand > 0.5
    entries_today << { time: '13:00', entry_type: 'entrada' }
  end

  entries_today.each do |entry|
    TimeEntry.create!(
      user: user,
      time_sheet: time_sheet_today,
      date: Date.today,
      time: entry[:time],
      entry_type: entry[:entry_type],
      status: 'registrado'
    )
  end
end

# Criar registro para o segundo usuário no dia atual, se ainda não existir
if Date.today.on_weekday? && !used_dates[user2.id].include?(Date.today)
  # Registrar que esta data está sendo usada para este usuário
  used_dates[user2.id] << Date.today

  # Para o segundo usuário, criar outro padrão para o dia atual
  time_sheet_today2 = TimeSheet.create!(
    user: user2,
    date: Date.today,
    status: 'incompleto',
    approval_status: 'pendente'
  )

  # Registros para o dia atual - usuário 2
  entries_today2 = [
    { time: '08:00', entry_type: 'entrada' },
    { time: '12:00', entry_type: 'saída' },
    { time: '13:05', entry_type: 'entrada' }
  ]

  entries_today2.each do |entry|
    TimeEntry.create!(
      user: user2,
      time_sheet: time_sheet_today2,
      date: Date.today,
      time: entry[:time],
      entry_type: entry[:entry_type],
      status: 'registrado'
    )
  end
end

puts "Seeds concluídos com sucesso!"
puts "----------------------------------------"
puts "Usuários criados:"
puts "- Email: funcionario@exemplo.com"
puts "- Senha: senha123"
puts ""
puts "- Email: maria@exemplo.com"
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
puts "----------------------------------------"
puts "Resumo de cenários criados:"
puts "- Registros dentro da tolerância (±15min): #{TimeSheet.where(justification: nil).where('approval_status != ?', 'pendente').count}"
puts "- Registros fora da tolerância sem justificativa: #{TimeSheet.where(justification: nil, approval_status: 'pendente').count}"
puts "- Registros com justificativa pendente: #{TimeSheet.where(justification_status: 'pendente').count}"
puts "- Registros com justificativa aprovada: #{TimeSheet.where(justification_status: 'aprovada').count}"
puts "- Registros com justificativa rejeitada: #{TimeSheet.where(justification_status: 'rejeitada').count}"