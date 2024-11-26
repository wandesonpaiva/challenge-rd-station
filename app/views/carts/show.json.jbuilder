json.cart do
  json.id @cart.id
  json.products @cart.cart_items do |item|
    json.id item.product.id
    json.name item.product.name
    json.quantity item.quantity
    json.unit_price item.product.price
    json.total_price item.product.price * item.quantity
  end
  json.total_price @cart.total_price
end