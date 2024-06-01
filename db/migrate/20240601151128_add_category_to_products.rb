class AddCategoryToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :category, :integer
  end
end
