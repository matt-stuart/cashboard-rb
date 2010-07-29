module Cashboard
  class TimeEntry < Base
    element :created_on, DateTime
    element :description
    element :invoice_line_item_id # readonly
    element :is_billable, Boolean
    element :is_running, Boolean # readonly
    element :line_item_id
    element :minutes, Integer
    element :minutes_with_timer, Integer # readonly
    element :person_id
    element :timer_started_at, DateTime # readonly
    
    # Starts or stops timer depending on its current state.
    #
    # Will return an object of Cashboard::Struct if another timer was stopped
    # during this toggle operation.
    #
    # Will return nil if no timer was stopped.
    def toggle_timer
      options = self.class.merge_options()
      options.merge!({:body => self.to_xml})
      response = self.class.put(self.links[:toggle_timer], options)
      
      # Raise special errors if not a success
      self.class.check_status_code(response)
      
      # Re-initialize ourselves with information from response
      initialize(response.parsed_response)
      
      if self.stopped_timer
        stopped_timer = Cashboard::Struct.new(self.stopped_timer)
      end
      
      stopped_timer || nil
    end
    
    # If a TimeEntry has no invoice_line_item_id set, then it 
    # hasn't been included on an invoice.
    def has_been_invoiced?
      !self.invoice_line_item_id.blank?
    end
    
  end
end