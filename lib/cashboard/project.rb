module Cashboard
  class Project < Base
    include Cashboard::Behaviors::Toggleable
    include Cashboard::Behaviors::ListsLineItems
    
    BILLING_CODES = {
      :non_billable => 0,
      :task_rate => 1,
      :employee_rate => 2
    }
    
    CLIENT_VIEW_TIME_CODES = {
      :show_when_invoiced => 0,
      :show_when_marked_billable => 1,
      :never => 2
    }
    
    element :billing_code, Integer
    element :client_name, String
    element :client_id, Integer
    element :client_type, String
    element :client_view_time_code, Integer
    element :completion_date, Date
    element :created_on, Date
    element :is_active, Boolean
    element :name, String
    element :rate, Float
    element :start_date, Date
    
    # Returns all employee ProjectAssignments
    def employee_project_assignments(options={})
      self.class.get_collection(
        self.links[:assigned_employees], Cashboard::ProjectAssignment, options
      )
    end

  end
end