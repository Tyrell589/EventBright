class ParticipationMailer < ApplicationMailer
  default from: 'mathieu.liem00@gmail.com'
 
  def event_participation_email(participation)
    @user = participation.user 
    @event = participation.event 
    mail(to: @user.email, subject: "Tu viens de t\'inscrire à l\'evenement #{@event.title}") 
  end
end
