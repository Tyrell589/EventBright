class EventsController < ApplicationController
  include EventsHelper
  before_action :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource #load @event even for non restful action like :submission_success https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Authorizing-controller-actions.md#choosing-actions
  before_action :amount_to_be_charged, only: [:show]
 
  # Cancancan take care of:
  # before_action :set_event, only: [:show, :edit, :update, :destroy]
  # before_action :ensure_current_user_is_administrator, only: [:edit, :update, :destroy]
  # before_action :ensure_event_is_validated, only: [:show]
  
  def index
    # Without cancancan, with a scope defined in event.rb model
    # @pagy, @events = pagy(Event.validated.with_attached_images.order("created_at DESC"), items: 9)
 
    # With cancancan, it's done already through the ability scope. The scoped events are loaded in @events
    @pagy, @events = pagy(@events.with_attached_images.order("created_at DESC"), items: 12)
  end
  
  def show
  end

  def new
  end

  def create
    @event.assign_attributes(administrator: current_user, start_date: parsed_datetime, duration: parsed_duration, price: formated_price)
    if @event.save 
      flash[:success] = "Your event has been created it will be reviewed & validated soon!"
      redirect_to submission_success_path(id: @event.id)
    else
      flash.now[:warning] = "Your event has not been created"
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      flash[:success] = "Event successfully edited !"
      redirect_to @event
    else
      flash.now[:warning] = "Event couldn't be edited"
      render :edit
    end
  end

  def destroy
    @event.destroy
    flash[:success] = "Event successfully deleted"
    redirect_to root_path
  end

  def submission_success
  end

private

  def event_params
    params.require(:event).permit(:title, :description, :location, :price, images: [])
  end  

  def parsed_datetime
    date = params.require(:event).permit(:starting_date)[:starting_date]
    time = params.require(:event).permit(:starting_time)[:starting_time]
    DateTime.parse("#{date} #{time}") if date.present? && time.present?
  end    

  def parsed_duration
    hours = params.require(:event).permit("duration(4i)")["duration(4i)"]
    minutes = params.require(:event).permit("duration(5i)")["duration(5i)"]
    minutes.to_i + hours.to_i * 60 
  end    

  def formated_price
    price = params.require(:event).permit(:price)[:price]
    price.to_i * 100
  end

  def amount_to_be_charged
    # Amount in cents
    @amount = @event.price
  end

# CanCanCan take car of:

# -Thanks to it's loading feature:

# def set_event
#   @event = Event.find(params[:id])
# end

# -Thanks to scoping to "administrator_id: user.id"

# def ensure_current_user_is_administrator
#   current_user_is_administrator?(@event)
# end

# -Thanks to scoping to "validated: true"

# def ensure_event_is_validated
#   unless @event.validated 
#     flash[:warning] = "This event is being reviewed for validation"
#     redirect_to root_path
#   end
# end
end