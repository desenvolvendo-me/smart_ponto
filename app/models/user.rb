class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :time_entries, dependent: :destroy
  has_many :time_sheets, dependent: :destroy
  has_one :user_preference, dependent: :destroy

  # Aprovações que o usuário fez (como gerente)
  has_many :approvals, class_name: 'TimeSheet', foreign_key: 'approved_by'

  validates :name, presence: true
  validates :employee_id, uniqueness: true, allow_blank: true

  after_create :create_default_preferences

  private

  def create_default_preferences
    create_user_preference unless user_preference
  end
end