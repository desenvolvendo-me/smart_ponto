class TimeSheet < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: 'User', foreign_key: 'approved_by', optional: true

  has_many :time_entries, dependent: :nullify

  STATUSES = ['incompleto', 'completo'].freeze
  APPROVAL_STATUSES = ['pendente', 'enviado', 'aprovado', 'rejeitado'].freeze

  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :approval_status, presence: true, inclusion: { in: APPROVAL_STATUSES }

  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :chronological, -> { order(date: :desc) }

  before_validation :set_default_statuses, on: :create
  after_save :calculate_total_hours

  def complete?
    status == 'completo'
  end

  def approved?
    approval_status == 'aprovado'
  end

  private

  def set_default_statuses
    self.status ||= 'incompleto'
    self.approval_status ||= 'pendente'
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
end
