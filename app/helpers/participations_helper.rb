module ParticipationsHelper
  def current_user_participation(event)
    Participation.where(user:current_user, event:event).first
  end

  def participation_where(user, event)
    Participation.where(user: user, event: event).first
  end
end