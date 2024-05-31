class AddCategoryToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :category, :integer
  end
end
