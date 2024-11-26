require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:cart) { Cart.create(total_price: 0) }

  describe "POST /add_item" do
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      before do
        post '/set_session', params: { cart_id: cart.id }
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "POST /cart" do
    let(:product) { FactoryBot.create(:product) }

    context "when a cart doesnt exist in the session" do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it "creates a new cart" do
        expect { subject }.to change { Cart.count }.by(1)
      end
    end

    context "when a cart does exist in the session" do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      before do
        post '/set_session', params: { cart_id: cart.id }
      end

      it "don't create a new cart" do
        expect { subject }.to change { Cart.count }.by(0)
      end
    end
  end

  describe "GET /show" do
    before do
      post '/set_session', params: { cart_id: cart.id }
    end

    subject do
      get '/cart', as: :json
    end

    it "returns the cart" do
      subject
      expect(response).to be_successful
    end
  end

  describe "DELETE /cart/:product_id" do
    context "when the product is in the cart" do
      subject do
        delete "/cart/#{product.id}", as: :json
      end

      before do
        post '/set_session', params: { cart_id: cart.id }
        cart.cart_items.create(product: product, quantity: 1)
      end

      let(:product) { FactoryBot.create(:product) }

      it "deletes the item from the cart" do
        expect { subject }.to change { CartItem.count }.by(-1)
      end
    end

    context "when the product is not in the cart" do
      subject do
        delete "/cart/#{product.id}", as: :json
      end

      before do
        post '/set_session', params: { cart_id: cart.id }
      end

      let(:product) { FactoryBot.create(:product) }

      it "returns not found" do
        expect { subject }.to change { CartItem.count }.by(0)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
