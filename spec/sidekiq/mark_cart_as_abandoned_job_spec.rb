require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let!(:recent_cart) { FactoryBot.create(:cart, last_interaction_at: 2.hours.ago, abandoned: false, total_price: 0) }
  let!(:old_cart) { FactoryBot.create(:cart, last_interaction_at: 4.hours.ago, abandoned: false, total_price: 0) }
  let!(:very_old_cart) { FactoryBot.create(:cart, last_interaction_at: 8.days.ago, abandoned: true, total_price: 0) }

  describe '#perform' do
    it 'marks carts as abandoned if inactive for more than 3 hours' do
      expect { MarkCartAsAbandonedJob.new.perform }
        .to change { old_cart.reload.abandoned }.from(false).to(true)
    end

    it 'does not mark carts as abandoned if active within 3 hours' do
      MarkCartAsAbandonedJob.new.perform
      expect(recent_cart.reload.abandoned).to be_falsey
    end

    it 'deletes carts abandoned for more than 7 days' do
      expect { MarkCartAsAbandonedJob.new.perform }
        .to change { Cart.exists?(very_old_cart.id) }.from(true).to(false)
    end

    it 'does not delete carts inactive for less than 7 days' do
      expect { MarkCartAsAbandonedJob.new.perform }
        .not_to change { Cart.exists?(old_cart.id) }
    end
  end
end
