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

  private

  def associate_time_sheet
    sheet = user.time_sheets.find_or_create_by(date: date)
    self.time_sheet = sheet
  end
end
