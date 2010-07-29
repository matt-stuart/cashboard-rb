module Cashboard
  class LineItem < Base
    TYPE_CODES = {
      :custom => 0,
      :task => 1,
      :product => 2
    }
    
    element :best_time_in_minutes, Integer
    element :created_on, DateTime
    element :description, String
    element :estimate_id, String
    element :flat_fee, Float
    element :is_complete, Boolean
    element :is_taxable, Boolean
    element :markup_percentage, Float
    element :price_per, Float
    element :project_id, String
    element :quantity_low, Float
    element :quantity_high, Float
    element :rank, Integer
    element :title, String
    element :type_code, Integer
    element :unit_label, String
    element :worst_time_in_minutes, Integer
  end
end