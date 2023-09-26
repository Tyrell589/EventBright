class Comment < ApplicationRecord
  # validations
  validates :content,
  presence: { message: "Content muse be present" }

  # Associations
  belongs_to :commenter, class_name: "User"
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy  
end
