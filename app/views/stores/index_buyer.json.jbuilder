json.array! @stores do |store|
  json.extract! store, :id, :name
  if store.image.attached?
    json.image_url rails_blob_url(store.image, only_path: true)
  end
end
