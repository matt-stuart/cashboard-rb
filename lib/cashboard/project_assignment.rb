module Cashboard
  class ProjectAssignment < Base
    element :bill_rate, Float
    element :has_access, Boolean
    element :pay_rate, Float
    element :person_id
    element :project_id
  end
end