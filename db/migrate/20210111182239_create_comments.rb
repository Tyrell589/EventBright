class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :commenter, null: false, index: true
      t.references :commentable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
