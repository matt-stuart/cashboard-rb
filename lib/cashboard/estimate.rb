module Cashboard
  class Estimate < Base
    include Cashboard::Behaviors::Toggleable
    include Cashboard::Behaviors::ListsLineItems
    
    element :assigned_id
    element :agreement_text
    element :client_id
    element :client_type
    element :created_on, DateTime
    element :deposit_amount, Float
    element :discount_percentage, Float
    element :document_template_id
    element :has_been_sent, Boolean
    element :intro_text
    element :is_active, Boolean
    element :name
    element :requires_agreement, Boolean
    element :sales_tax, Float
    element :sales_tax_2, Float
    element :sales_tax_2_cumulative, Boolean
    # Read only attributes. Can't set these via API
    element :discount_best, Float
    element :discount_worst, Float
    element :item_actual_best, Float
    element :item_actual_worst, Float
    element :item_cost_best, Float
    element :item_cost_worst, Float
    element :item_profit_best, Float
    element :item_profit_worst, Float
    element :item_taxable_best, Float
    element :item_taxable_worst, Float
    element :price_best, Float
    element :price_worst, Float
    element :tax_cost_best, Float
    element :tax_cost_worst, Float
    element :tax_cost_2_best, Float
    element :tax_cost_2_worst, Float
    element :time_best, Float
    element :time_worst, Float
     
  end
end