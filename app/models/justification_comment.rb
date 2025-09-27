class JustificationComment < ApplicationRecord
  belongs_to :time_sheet
  belongs_to :user
  belongs_to :parent_comment, class_name: 'JustificationComment', optional: true
  has_many :replies, class_name: 'JustificationComment', foreign_key: 'parent_comment_id', dependent: :destroy

  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :level, inclusion: { in: [1, 2, 3] }

  validate :validate_comment_level_sequence
  validate :validate_justification_status
  validate :validate_user_permissions

  scope :root_comments, -> { where(parent_comment_id: nil) }
  scope :by_level, ->(level) { where(level: level) }
  scope :chronological, -> { order(:created_at) }

  def manager_comment?
    level == 1 || level == 3
  end

  def employee_reply?
    level == 2
  end

  def can_be_replied?
    level < 3
  end

  private

  def validate_comment_level_sequence
    return unless time_sheet

    existing_comments = time_sheet.justification_comments.chronological

    case level
    when 1
      if existing_comments.any?
        errors.add(:level, 'Apenas um comentário inicial do gerente é permitido')
      end
      unless user.role == 'gestor'
        errors.add(:user, 'Apenas gerentes podem fazer o comentário inicial')
      end
    when 2
      manager_comment = existing_comments.find { |c| c.level == 1 }
      if manager_comment.nil?
        errors.add(:level, 'Funcionário só pode responder após comentário do gerente')
      end
      if existing_comments.any? { |c| c.level == 2 }
        errors.add(:level, 'Apenas uma réplica do funcionário é permitida')
      end
      unless user == time_sheet.user
        errors.add(:user, 'Apenas o funcionário pode fazer a réplica')
      end
    when 3
      employee_reply = existing_comments.find { |c| c.level == 2 }
      if employee_reply.nil?
        errors.add(:level, 'Gerente só pode fazer tréplica após réplica do funcionário')
      end
      if existing_comments.any? { |c| c.level == 3 }
        errors.add(:level, 'Apenas uma tréplica do gerente é permitida')
      end
      unless user.role == 'gestor'
        errors.add(:user, 'Apenas gerentes podem fazer a tréplica')
      end
    end
  end

  def validate_justification_status
    unless time_sheet&.justification_status == 'pendente'
      errors.add(:time_sheet, 'Comentários só são permitidos quando justificativa está "Enviado para aprovação"')
    end
  end

  def validate_user_permissions
    return unless time_sheet && user

    if manager_comment? && user.role != 'gestor'
      errors.add(:user, 'Apenas gerentes podem comentar nos níveis 1 e 3')
    end

    if employee_reply? && user != time_sheet.user
      errors.add(:user, 'Apenas o funcionário responsável pode fazer a réplica')
    end
  end
end