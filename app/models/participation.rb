class Participation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :event

  # Callbacks
  after_create :participation_email
  # Scopes
  scope :of_event, -> (event) { where(event: event) } 

  def participation_email
    ParticipationMailer.event_participation_email(self).deliver_now
  end
end
