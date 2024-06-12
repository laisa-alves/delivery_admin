# json.array! @orders, :id, :store_id, :state, :created_at

json.orders @orders do |order|
    json.extract! order, :id, :state, :created_at, :updated_at
    json.custumer order.buyer, :id, :email
    json.store order.store, :id, :name
    json.order_items order.order_items do |order_item|
      json.extract! order_item, :id, :amount
      json.set! :unit_price, order_item.price
      json.extract! order_item, :total_price
      json.product order_item.product, :id, :title
    end
    json.total order.total_order_price
end
