require 'rails_helper'

RSpec.describe TimeEntry, type: :model do
  describe 'weekend registration validation' do
    let(:weekend_date) { Date.new(2026, 5, 17) }

    it 'allows gestor to register on weekend without explicit release' do
      user = User.create!(
        email: 'gestor@example.com',
        password: '123456',
        name: 'Gestor',
        role: 'gestor',
        weekend_registration_allowed: false
      )

      time_entry = described_class.new(
        user: user,
        date: weekend_date,
        time: Time.zone.parse('09:00'),
        entry_type: 'entrada',
        status: 'registrado'
      )

      expect(time_entry).to be_valid
    end

    it 'blocks non-manager on weekend without explicit release' do
      user = User.create!(
        email: 'colaborador@example.com',
        password: '123456',
        name: 'Colaborador',
        role: 'funcionario',
        weekend_registration_allowed: false
      )

      time_entry = described_class.new(
        user: user,
        date: weekend_date,
        time: Time.zone.parse('09:00'),
        entry_type: 'entrada',
        status: 'registrado'
      )

      expect(time_entry).not_to be_valid
      expect(time_entry.errors[:date]).to include(
        'não permitido para registro em fim de semana. Liberação automática somente para gestor.'
      )
    end

    it 'keeps allowing explicit weekend release for non-manager' do
      user = User.create!(
        email: 'liberado@example.com',
        password: '123456',
        name: 'Liberado',
        role: 'funcionario',
        weekend_registration_allowed: true
      )

      time_entry = described_class.new(
        user: user,
        date: weekend_date,
        time: Time.zone.parse('09:00'),
        entry_type: 'entrada',
        status: 'registrado'
      )

      expect(time_entry).to be_valid
    end
  end
end
