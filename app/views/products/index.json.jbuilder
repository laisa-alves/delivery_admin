json.result do
  if params[:page].present?
    json.pagination do
      current = @products.current_page
      total = @products.total_pages
      per_page = @products.limit_value

      json.current current
      json.total total
      json.per_page per_page
      json.count @products.total_count
      json.previous (current > 1 ? (current - 1) : nil )
      json.next (current == total ? nil : (current + 1))
    end
  end

  json.products do
    json.array! @products, partial: "products/product", as: :product
  end
end
