class ImagesController < ApplicationController
  before_action :set_event
  before_action :set_image


  def destroy
    @image.purge
    redirect_to edit_event_path(@event)
  end

# private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_image
    @image = ActiveStorage::Attachment.find(params[:id])
  end
end
