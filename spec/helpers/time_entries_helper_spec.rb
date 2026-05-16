require 'rails_helper'
RSpec.describe TimeEntriesHelper, type: :helper do
  describe '#can_register_on_date?' do
    let(:weekend_date) { Date.new(2026, 5, 17) }

    it 'returns true for gestor even without explicit release' do
      user = User.new(role: 'gestor', weekend_registration_allowed: false)

      expect(helper.can_register_on_date?(user, weekend_date)).to be(true)
    end

    it 'returns false for non-manager without explicit release' do
      user = User.new(role: 'funcionario', weekend_registration_allowed: false)

      expect(helper.can_register_on_date?(user, weekend_date)).to be(false)
    end
  end

  describe '#weekend_registration_tooltip' do
    let(:weekend_date) { Date.new(2026, 5, 17) }
    let(:weekday_date) { Date.new(2026, 5, 18) }

    it 'explains that automatic release is only for manager when user is blocked' do
      user = User.new(role: 'funcionario', weekend_registration_allowed: false)

      expect(helper.weekend_registration_tooltip(user, weekend_date)).to eq(
        'Não liberado registrar ponto no fim de semana. Liberação automática somente para gestor.'
      )
    end

    it 'returns an informational message for gestor on weekend' do
      user = User.new(role: 'gestor', weekend_registration_allowed: false)

      expect(helper.weekend_registration_tooltip(user, weekend_date)).to eq(
        'Como gestor, a regra de bloqueio de fim de semana não se aplica ao seu perfil.'
      )
    end

    it 'does not return tooltip on weekdays' do
      user = User.new(role: 'funcionario', weekend_registration_allowed: false)

      expect(helper.weekend_registration_tooltip(user, weekday_date)).to be_nil
    end
  end
end
