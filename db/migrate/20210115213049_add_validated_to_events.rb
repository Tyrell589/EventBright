class AddValidatedToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :validated, :boolean, default: false
  end
end
