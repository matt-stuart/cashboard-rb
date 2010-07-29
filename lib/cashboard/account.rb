module Cashboard
  class Account < Base    
    # Account is the only singular resource for the Cashboard API.
    def self.resource_name; 'account'; end
    
    # We get some sub-resources that we need to turn into
    # Cashboard::Structs so we can access their information
    # in a friendly way.
    def initialize(hash={})
      super hash
      self.owner = Cashboard::Struct.new(self.owner)
      self.company = Cashboard::Struct.new(self.company)
      self
    end
    
    def href
      "/#{self.class.resource_name}"
    end
    
  end
end