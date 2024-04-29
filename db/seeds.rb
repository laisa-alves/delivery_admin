# Cria ou retorna o admin
admin = User.find_by(email: "admin@example.com")

if !admin
  admin = User.new(
    email: "admin@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :admin
  )
  admin.save!
end

# Cria novas lojas
[ "Spice Grill", "Smokestack Box" ].each do |store|
  user = User.new(
    email: "#{store.split.map { |s| s.downcase }.join(".")}@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :seller
  )
  user.save!

  Store.find_or_create_by!(name: store, user: user)
end

# Cria produtos para as lojas anteriores
["Scotch Eggs", "Chicken Parm", "Carbonara", "Kebab", "Fish and Chips"].each do |dish|
  store = Store.find_by(name: "Spice Grill")
  Product.find_or_create_by!(title: dish, store: store)
end

["Mushroom Risotto", "Caesar Salad", "Tuna Sashimi", "Chicken Milanese"].each do |dish|
  store = Store.find_by(name: "Smokestack Box")
  Product.find_or_create_by!(title: dish, store: store)
end

# Cria usuários do tipo buyer
["Aracelis Weissnat", "Lorenza Upton", "Arlen Brown"].each do |buyer|
  email = buyer.split.map { |s| s.downcase }.join(".")
  user = User.find_by(email: email)
  if !user
    user = User.new(
      email: "#{email}@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: "buyer"
    )
    user.save!
  end
end
