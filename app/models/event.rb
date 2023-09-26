class Event < ApplicationRecord
  # virtual attributes to retrieve date and time in 2 different fields
  attr_accessor :starting_date, :starting_time
  
  # Associations
  has_many_attached :images
  belongs_to :administrator, class_name: "User"
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  # Validations
  validate :start_date_cannot_be_in_the_past
  validate :duration_must_be_positif_multiple_of_5
  validates :images,
    attached: true,
    allow_blank: true,
    content_type: ['image/png', 'image/jpg', 'image/jpeg'],
    limit: { min: 0, max: 3, message: 'Maximum 3 images allowed' }                                    
  validates_numericality_of :price,
    greater_than_or_equal_to:  0,
    less_than: 100000,
    only_integer: true,
    message: 'Price must be between 0 and 1000' 
  validates :duration, numericality: { only_integer: true }
  validates :title, presence: { message: "You must choose a title" }, length: { in: 5..140 }
  validates :description, presence: { message: "You must add a description" }, length: { in: 5..10_000 }
  validates :location, presence: { message: "You must choose a location" }
  # validates :starting_date, presence: { message: "You must choose a starting date" }
  # validates :starting_time, presence: { message: "You must choose a starting time" }

  # Scopes
  scope :validated, -> { where(validated: true) }
  scope :latest,-> (nb) { order(created_at: :desc).limit(nb) }

  def start_date_cannot_be_in_the_past
    errors.add(:start_date, "time and date must be present or can't be in the past") unless start_date.present? && DateTime.parse("#{start_date}") >= DateTime.now.change(offset: "+0000")
  end

  def duration_must_be_positif_multiple_of_5
    errors.add(:duration, "must be a multiple of 5 and at least 5 minutes") unless duration.present? && duration > 0 && duration % 5 == 0
  end

  # instance methods

  def starting_date_time
    self.start_date.strftime("%Y-%m-%d at %H:%M")
  end

  def ending_date_date_time
    end_date = self.start_date + self.duration.minutes
    end_date.strftime("%Y-%m-%d at %H:%M")
  end

  def is_free?
    self.price == 0
  end

  #return only the attachement objects associated with the events that or saved in db
  def event_images 
    images.select{ |img| img.persisted? }
  end
end
