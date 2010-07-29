# Standard interface to toggle the status of something between Active
# and Closed inside Cashboard.
module Cashboard::Behaviors::Toggleable
  # Toggles status of the project between active/closed
  # and sets appropriate variable.
  def toggle_status
    options = self.class.merge_options()
    options.merge!({:body => self.to_xml})
    response = self.class.put(self.links[:toggle_status], options)
    begin 
      self.class.check_status_code(response)
    rescue
      return false
    end
    self.is_active = !self.is_active
    return true
  end
end