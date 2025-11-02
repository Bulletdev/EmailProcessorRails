require 'rails_helper'

RSpec.describe EmailLog do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, success: 1, failed: 2) }
  end

  describe 'scopes' do
    let!(:success_log) { create(:email_log, status: :success) }
    let!(:failed_log) { create(:email_log, :failed) }

    it 'filters successful logs' do
      expect(described_class.successful).to include(success_log)
      expect(described_class.successful).not_to include(failed_log)
    end

    it 'filters failed logs' do
      expect(described_class.failed_logs).to include(failed_log)
      expect(described_class.failed_logs).not_to include(success_log)
    end

    it 'orders by recent first' do
      create(:email_log, created_at: 1.day.ago)
      expect(described_class.recent_first.first).to eq(failed_log)
    end
  end
end
