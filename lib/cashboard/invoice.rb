module Cashboard
  class Invoice < Base
    element :assigned_id
    element :balance, Float # readonly
    element :client_id
    element :client_type
    element :created_on, DateTime
    element :discount, Float # readonly
    element :discount_percentage, Float
    element :document_template_id
    element :due_date, Date
    element :early_period_in_days, Integer
    element :has_been_sent, Boolean
    element :include_expenses, Boolean
    element :include_pdf, Boolean
    element :include_time_entries, Boolean
    element :invoice_date, Date
    element :item_actual, Float # readonly
    element :item_cost, Float # readonly
    element :item_profit, Float # readonly
    element :item_taxable, Float # readonly
    element :late_fee, Float # readonly
    element :late_percentage, Float
    element :late_period_in_days, Integer
    element :notes
    element :payment_total, Float # readonly
    element :post_reminder_in_days, Integer
    element :pre_reminder_in_days, Integer
    element :sales_tax, Float
    element :sales_tax_2, Float
    element :sales_tax_2_cumulative, Boolean
    element :total, Float # readonly
    element :total_quantity, Float # readonly
    
    # Returns all associated LineItems
    def line_items(options={})
      self.class.get_collection(
        self.links[:line_items], Cashboard::InvoiceLineItem, options
      )
    end
    
    # Imports uninvoiced items (time entries, expenses, flat fee tasks) 
    # that belong to the same client that this invoice was created for.
    #
    # Either raises a Cashboard error (errors.rb) or returns a collection
    # of Cashboard::InvoiceLineItem objects.
    def import_uninvoiced_items(project_ids={}, start_date=nil, end_date=nil)
      xml_options = get_import_xml_options(project_ids, start_date, end_date)
      
      options = self.class.merge_options()
      options.merge!({:body => xml_options})
      response = self.class.put(self.links[:import_uninvoiced_items], options)
      
      self.class.check_status_code(response)
      
      collection = response.parsed_response[Cashboard::InvoiceLineItem.resource_name.singularize]      
      collection.map do |h| 
        Cashboard::InvoiceLineItem.new(h)
      end
    end
        
    def get_import_xml_options(project_ids, start_date, end_date)
      xml_options = ''
      xml = Builder::XmlMarkup.new(:target => xml_options, :indent => 2)
      xml.instruct!
      xml.projects do
        project_ids.each {|pid| xml.id pid} if project_ids
      end
      xml.start_date start_date
      xml.end_date end_date
      
      return xml_options  
    end
  end
end