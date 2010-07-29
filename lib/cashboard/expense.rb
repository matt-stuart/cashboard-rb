module Cashboard
  class Expense < Base
    element :amount, Float
    element :category
    element :created_on, DateTime
    element :description
    element :invoice_line_item_id # read only
    element :is_billable, Boolean
    element :payee_id
    element :payee_type
    element :person_id
    element :project_id
  end
end