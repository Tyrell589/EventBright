module Admin
  class EventSubmissionsController < Admin::ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy, :validate]

    def index 
      # kaminari pagination
      @events = Event.where(validated: false).order("created_at ASC").page(params[:page]).per(20)
    end

    def show
    end

    def edit
    end

    def update
      if @event.update(event_params)
        flash[:success] = "Event successfully edited !"
        redirect_to edit_admin_event_submission_path(@event)
      else
        flash.now[:error] = "Event couldn't be edited"
        render :edit
      end
    end

    def destroy
      @event.destroy
      flash[:success] = "Event successfully deleted"
      redirect_to admin_event_submissions_path
    end

    def validate
      if @event.update(event_validate_params)
        flash[:success] = "Event successfully validated"
        redirect_to admin_event_submissions_path
      else
        flash[:success] = "Event counldn't be validated"
        redirect_to admin_event_submissions_path
      end
    end

  private 

    def set_event 
      @event = Event.find(params[:id])
    end

    def event_params 
      params.require(:event).permit(:title, :description, :location, :price, :start_date)
    end

    def event_validate_params 
      params.require(:event).permit(:validated)
    end

  end
end
