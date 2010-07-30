module Cashboard
  class Unauthorized < StandardError; end
  
  class HTTPError < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
      super
    end
    
    def to_s
      
      #hint = response.response.body.nil? ? nil : response.response.body
      #"#{self.class.to_s} : #{response.code}#{" - #{hint}" if hint}"
      response.inspect
    end
  end
  
  class Forbidden < HTTPError; end
  class RateLimited < HTTPError; end
  class NotFound < HTTPError; end
  class PaymentRequired < HTTPError; end
  class Unavailable < HTTPError; end
  class ServerError < HTTPError; end
  
  class BadRequest < HTTPError
    # Custom parses our "errors" return XML
    def to_s
      response.response.body 
    end
    
    # Returns a hash of errors keyed on field name.
    # 
    # Return Example
    #   {
    #     :field_name_one => "Error message",
    #     :field_name_two => "Error message"
    #   }
    def errors
      parsed_errors = XmlSimple.xml_in(response.response.body)
      error_hash = {}
      parsed_errors['error'].each do |e|
        error_hash[e['field']] = e['content']
      end
      return error_hash
    end
  end
end