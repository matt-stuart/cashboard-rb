module Cashboard
  class InvoicePayment < Base
    element :invoice_id
    element :payment_id
    element :amount, Float
  end
end