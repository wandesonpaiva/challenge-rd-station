require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { FactoryBot.create(:cart, total_price: 0) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned }.from(false).to(true)
    end
  end
end
