user = User.find_by(email: "store@example.com")

if !user
  user = User.new(
    email: "store@example.com",
    password: "123456",
    password_confirmation: "123456"
  )
  user.save!
end

[ "Spice Grill", "Smokestack Box" ].each do |store|
  Store.find_or_create_by!(name: store, user: user)
end

["Scotch Eggs", "Chicken Parm", "Carbonara", "Kebab", "Fish and Chips"].each do |dish|
  store = Store.find_by(name: "Spice Grill")
  Product.find_or_create_by!(title: dish, store: store)
end

["Mushroom Risotto", "Caesar Salad", "Tuna Sashimi", "Chicken Milanese"].each do |dish|
  store = Store.find_by(name: "Smokestack Box")
  Product.find_or_create_by!(title: dish, store: store)
end
