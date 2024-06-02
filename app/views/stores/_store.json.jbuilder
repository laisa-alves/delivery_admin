json.extract! store, :id, :name, :category, :description, :active, :created_at, :updated_at
if store.image.attached?
  json.image_url rails_blob_url(store.image, only_path: true)
end
json.url store_url(store, format: :json)
