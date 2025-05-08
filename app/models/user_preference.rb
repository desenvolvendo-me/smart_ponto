class UserPreference < ApplicationRecord
  belongs_to :user

  # Defina valores padrão se necessário
  attribute :theme, :string, default: 'light'
  attribute :date_format, :string, default: 'DD/MM/AAAA'
  attribute :time_format, :string, default: '24h'
  attribute :first_day_of_week, :string, default: 'monday'
  attribute :language, :string, default: 'pt-BR'
  attribute :require_password_on_sign, :boolean, default: true
end