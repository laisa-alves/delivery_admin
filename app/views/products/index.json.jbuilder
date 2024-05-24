json.result do
  json.products do
    json.array! @products do |product|
      json.extract! product, :id, :title, :price, :description
      json.image_url rails_blob_url(product.image, only_path: true) if product.image.attached?
    end
  end
end
