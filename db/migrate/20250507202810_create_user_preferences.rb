# Migração para criar a tabela user_preferences
class CreateUserPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true

      # Informações pessoais adicionais
      t.string :phone_number
      t.string :secondary_email
      t.string :language, default: 'pt-BR'

      # Preferências de tema/visualização
      t.string :theme, default: 'light'
      t.string :date_format, default: 'DD/MM/AAAA'
      t.string :time_format, default: '24h'
      t.string :first_day_of_week, default: 'monday'

      # Preferências de autenticação
      t.boolean :require_password_on_sign, default: true

      t.timestamps
    end
  end
end