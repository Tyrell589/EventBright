class StaticPagesController < ApplicationController
  load_and_authorize_resource :event, :parent => false, only: [:home]

  def home
    @events = @events.latest(8).with_attached_images
  end

  def contact
  end

  def about
  end
end
