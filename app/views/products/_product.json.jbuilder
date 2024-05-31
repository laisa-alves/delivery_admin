json.extract! product, :id, :title, :price, :description, :created_at, :updated_at, :active
json.image_url rails_blob_url(product.image, only_path: true) if product.image.attached?
