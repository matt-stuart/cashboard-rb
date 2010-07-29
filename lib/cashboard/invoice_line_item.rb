module Cashboard
  class InvoiceLineItem < Base
    element :description
    element :flat_fee, Float
    element :invoice_id
    element :invoice_schedule_id
    element :is_taxable, Boolean
    element :markup_percentage, Float
    element :price_per, Float
    element :quantity, Float
    element :rank, Integer
    element :title
    element :total, Float # readonly
  end
end