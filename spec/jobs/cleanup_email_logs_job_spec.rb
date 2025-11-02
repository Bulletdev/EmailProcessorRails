require 'rails_helper'

RSpec.describe CleanupEmailLogsJob do
  describe '#perform' do
    before do
      # Clear any existing email logs to ensure test isolation
      EmailLog.destroy_all
    end

    let!(:old_log_1) { create(:email_log, created_at: 100.days.ago) }
    let!(:old_log_2) { create(:email_log, created_at: 95.days.ago) }
    let!(:recent_log_1) { create(:email_log, created_at: 30.days.ago) }
    let!(:recent_log_2) { create(:email_log, created_at: 1.day.ago) }

    context 'with default retention period (90 days)' do
      it 'deletes logs older than 90 days' do
        expect do
          described_class.perform_now
        end.to change(EmailLog, :count).by(-2)

        expect(EmailLog.exists?(old_log_1.id)).to be false
        expect(EmailLog.exists?(old_log_2.id)).to be false
        expect(EmailLog.exists?(recent_log_1.id)).to be true
        expect(EmailLog.exists?(recent_log_2.id)).to be true
      end

      it 'returns the number of deleted logs' do
        result = described_class.perform_now

        expect(result[:deleted_count]).to eq(2)
        expect(result[:cutoff_date]).to be_within(1.second).of(90.days.ago)
      end
    end

    context 'with custom retention period' do
      it 'deletes logs older than specified days' do
        expect do
          described_class.perform_now(60)
        end.to change(EmailLog, :count).by(-2)
      end

      it 'keeps logs within the retention period' do
        described_class.perform_now(120)

        expect(EmailLog.count).to eq(4)
      end
    end

    context 'when there are no old logs' do
      before do
        EmailLog.where(id: [old_log_1.id, old_log_2.id]).destroy_all
      end

      it 'does not delete any logs' do
        expect do
          described_class.perform_now
        end.not_to change(EmailLog, :count)
      end

      it 'returns zero deleted count' do
        result = described_class.perform_now

        expect(result[:deleted_count]).to eq(0)
      end
    end
  end
end
