class ParticipationsController < ApplicationController
  include EventsHelper
    before_action :authenticate_user!
    before_action :set_event, only: [:index, :new, :create, :thanks] # @event is another model, we load it in a traditional way using a before_action (required to be find with :event_id instead of :id)
    load_and_authorize_resource only: [:index, :destroy]
    # The 2 bellow require @event to be set first for the :new, :create & :thanks (wich is done in the before_action :set_event) 
    before_action :amount_to_be_charged, only: [:new, :create, :thanks]
    before_action :description, only: [:new, :create]
    
  def index    
    # https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-controller-actions#load_resource
    @participations = @participations.of_event(@event) # @particiaptions loaded is a scope (scoped with the specified permissions). It's possible to scope on it with other conditions.
  end

  def new
    @participation = Participation.new(event: @event)
    authorize! :new, @participation
  end

  def create
    @participation = Participation.new(event: @event, user: current_user)
    authorize! :create, @participation # return here if authorization denied
    if @amount == 0 
      @participation.save(user: current_user, event: @event)
      flash[:success] = "Your are part of this event !"
      redirect_to thanks_path(event_id: @event.id)
    else
      begin
      #Best practice for stripe integration
      # https://rails.devcamp.com/trails/ruby-gem-walkthroughs/campsites/payment/guides/how-to-integrate-stripe-payments-in-a-rails-application-charges

      customer = StripeTool.create_customer(
                  email: params[:stripeEmail],
                  stripe_token: params[:stripeToken],
                 )

      charge = StripeTool.create_charge(
                customer_id: customer.id,
                amount: @amount,
                description: @description,
                currency: 'eur',
               )

      Participation.create(user: current_user, event: @event)

      redirect_to thanks_path(event_id: @event.id)

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to @event
      end
    end
  end
  
  def destroy
    @participation.destroy
    flash[:info] = "You are no longer part of this event"
    redirect_back(fallback_location: root_path)
  end

  def thanks
  end
  
private

  def set_event
    @event = Event.find(params[:event_id])
  end

  
  def amount_to_be_charged
    # Amount in cents
    @amount = @event.price
  end
  
  def description
    @description = @event.title
  end
  
  # def ensure_current_user_is_not_already_particitpant 
  #   if current_user_already_participant?(@event)
  #     flash[:warning] = "You're already part of this event"
  #     redirect_to @event
  #   end
  # end
  
  # def ensure_current_user_is_administrator
  #   current_user_is_administrator?(@event)
  # end
end