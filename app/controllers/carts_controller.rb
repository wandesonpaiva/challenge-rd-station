class CartsController < ApplicationController
  ## TODO Escreva a lógica dos carrinhos aqui
  def create
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create(total_price: 0, last_interaction_at: Time.now)
    session[:cart_id] = @cart.id

    if @cart.cart_items.exists?(product_id: params[:product_id].to_i)
      item = @cart.cart_items.find_by(product_id: params[:product_id].to_i)
      item.quantity += params[:quantity].to_i
    else
      @cart.cart_items.create(
        product_id: params[:product_id].to_i,
        quantity: params[:quantity].to_i
      )
      @cart.last_interaction_at = Time.now
    end

    if @cart.save
      render :show, status: :created
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  def show
    @cart = Cart.find_by(id: session[:cart_id])

    render :show
  end

  def add_item
    @cart = Cart.find_by(id: session[:cart_id])

    if @cart.cart_items.exists?(product_id: params[:product_id].to_i)
      item = @cart.cart_items.find_by(product_id: params[:product_id].to_i)
      item.quantity += params[:quantity].to_i
      item.save
    else
      @cart.cart_items.create(
        product_id: params[:product_id].to_i,
        quantity: params[:quantity].to_i
      )
    end
    @cart.update(last_interaction_at: Time.now)

    render :show
  end

  def remove_item
    @cart = Cart.find_by(id: session[:cart_id])
    item = @cart.cart_items.find_by(product_id: params[:product_id].to_i)

    if item
      item.destroy
      @cart.update(last_interaction_at: Time.now)
      render :show
    else
      render json: { error: "Item not found" }, status: :not_found
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity)
  end
end
