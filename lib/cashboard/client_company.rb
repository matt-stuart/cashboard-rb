module Cashboard
  class ClientCompany < Base
    element :name
    element :address
    element :address2
    element :city
    element :state
    element :zip
    element :country_code
    element :url
    element :telephone
    element :currency_type_code
    element :notes
    element :custom_1
    element :custom_2
    element :custom_3
    
    # Returns all associated CompanyMemberships
    def memberships(options={})
      self.class.get_collection(
        self.links[:memberships], Cashboard::CompanyMembership, options
      )
    end
  end
end