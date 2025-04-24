class TimeSheet < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: 'User', foreign_key: 'approved_by', optional: true

  has_many :time_entries, dependent: :destroy

  TOLERANCE_MINUTES = 15
  STATUSES = ['incompleto', 'completo'].freeze
  APPROVAL_STATUSES = ['pendente', 'enviado', 'aprovado', 'rejeitado'].freeze
  JUSTIFICATION_STATUSES = ['sem_justificativa', 'pendente', 'aprovada', 'rejeitada'].freeze

  validates :justification_status, inclusion: { in: JUSTIFICATION_STATUSES }, allow_nil: true
  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :approval_status, presence: true, inclusion: { in: APPROVAL_STATUSES }

  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :chronological, -> { order(date: :desc) }
  scope :submitted, -> { where(approval_status: 'enviado') }

  before_validation :set_default_statuses, on: :create
  after_save :calculate_total_hours

  def complete?
    status == 'completo'
  end

  def approved?
    approval_status == 'aprovado'
  end

  def total_hours
    entries = time_entries.order(:time)
    return "0.0" if entries.count < 2

    total_seconds = 0

    entries.each_slice(2) do |pair|
      if pair.length == 2
        # Calcula a diferença entre saída e entrada
        diff_seconds = pair[1].time - pair[0].time
        total_seconds += diff_seconds
      end
    end

    # Converte segundos para horas com formato "xx.x"
    (total_seconds / 3600.0).round(1).to_s
  end

  def self.to_csv
    require 'csv'

    # Obter os nomes reais das colunas do modelo
    # Exclui algumas colunas internas que não queremos exportar
    columns = column_names.reject { |c| %w[created_at updated_at].include?(c) }

    CSV.generate(headers: true) do |csv|
      # Usar os nomes das colunas como cabeçalho
      csv << columns

      # Para cada registro, incluir os valores de cada coluna
      all.each do |time_sheet|
        csv << columns.map do |column|
          value = time_sheet.send(column)
          # Formatar datas e horas se necessário
          if value.is_a?(Date)
            value.strftime('%d/%m/%Y')
          elsif value.is_a?(Time)
            value.strftime('%H:%M')
          else
            value
          end
        end
      end
    end
  end

  def within_tolerance?
    return true unless total_hours.present?

    # Converte para decimal se for string
    hours = total_hours.to_f

    # Calcula a diferença em relação às 8 horas padrão de trabalho
    difference_hours = (hours - 8.0).abs

    # Converte diferença para minutos
    difference_minutes = difference_hours * 60

    # Verifica se está dentro da tolerância
    difference_minutes <= TOLERANCE_MINUTES
  end

  private

  def set_default_statuses
    self.status ||= 'incompleto'
    self.approval_status ||= 'pendente'
    self.justification_status ||= 'sem_justificativa'
  end

  def calculate_total_hours
    entries = time_entries.order(:time)
    return if entries.count < 2 || entries.count.odd?

    total = 0
    entries.each_slice(2) do |entry_pair|
      next unless entry_pair.size == 2
      next unless entry_pair[0].entry_type == 'entrada' && entry_pair[1].entry_type == 'saída'

      entry_time = entry_pair[0].time
      exit_time = entry_pair[1].time

      hours = (exit_time.to_i - entry_time.to_i) / 3600.0
      total += hours
    end

    update_column(:total_hours, total)
    update_column(:status, 'completo') if entries.count >= 4
  end

  def requires_justification?
    return false if within_tolerance?
    return false if justification.present?

    # Fora da tolerância e sem justificativa
    true
  end
end
