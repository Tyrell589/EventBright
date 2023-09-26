module EventsHelper
  # Not possible to have them instance variables cuz of current_user
  def current_user_already_participant?(event)
    event.participants.include?(current_user)
  end

  def current_user_is_administrator?(event)
    event.administrator == current_user
  end

  def display_status(event)
    event.validated ? 'Validated' : 'In process'
  end
end