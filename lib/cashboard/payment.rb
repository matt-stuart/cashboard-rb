module Cashboard
  class Payment < Base
    element :amount, Float
    element :assigned_id
    element :client_id
    element :client_type
    element :created_on, Date
    element :document_template_id
    element :estimate_id
    element :notes
    element :person_id
    element :transaction_id
    
    # Returns all InvoicePayments associated with this payment
    def invoice_payments(options={})
      self.class.get_collection(
        self.links[:invoices], Cashboard::InvoicePayment, options
      )
    end
    
  end
end