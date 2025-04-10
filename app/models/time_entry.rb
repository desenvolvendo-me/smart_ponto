class TimeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :time_sheet, optional: true

  ENTRY_TYPES = ['entrada', 'saída'].freeze
  STATUSES = ['registrado', 'aprovado', 'rejeitado'].freeze

  validates :date, presence: true
  validates :time, presence: true
  validates :entry_type, presence: true, inclusion: { in: ENTRY_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :by_date, ->(date) { where(date: date) }
  scope :chronological, -> { order(:date, :time) }

  before_save :associate_time_sheet
  after_save :update_time_sheet_totals
  after_destroy :update_time_sheet_totals

  private

  def associate_time_sheet
    sheet = user.time_sheets.find_or_create_by(date: date)
    self.time_sheet = sheet
  end

  def update_time_sheet_totals
    # Garantir que temos uma time_sheet associada
    return unless time_sheet

    # Recarregar a time_sheet do banco para garantir dados atualizados
    time_sheet.reload

    # Chamar o método para calcular as horas totais
    # Verifica se o método existe e é público, senão usa send
    if time_sheet.respond_to?(:calculate_total_hours)
      time_sheet.calculate_total_hours
    else
      time_sheet.send(:calculate_total_hours)
    end
  end
end