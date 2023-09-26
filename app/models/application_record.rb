class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def creation_date_and_time
    self.created_at.utc.strftime("%Y-%m-%d at %H:%M")
  end
end


