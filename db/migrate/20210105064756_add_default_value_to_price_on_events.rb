class AddDefaultValueToPriceOnEvents < ActiveRecord::Migration[5.2]
  def change
    change_column_default :events, :price, 0
  end
end
