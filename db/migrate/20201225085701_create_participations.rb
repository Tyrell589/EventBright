class CreateParticipations < ActiveRecord::Migration[5.2]
  def change
    create_table :participations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :event, null: false, foreign_key: true, index: true
      t.string :stripe_customer_id

      t.timestamps
    end
  end
end
