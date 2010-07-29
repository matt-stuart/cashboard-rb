module Cashboard
  class ClientContact < Base
    element :api_key
    element :last_login, DateTime
    element :login_count, Integer
    element :address
    element :address2
    element :city
    element :country_code
    element :currency_type_code
    element :custom_1
    element :custom_2
    element :custom_3
    element :email_address
    element :first_name
    element :last_name
    element :notes
    element :password
    element :state
    element :telephone
    element :url
    element :zip
    
    # Returns all associated CompanyMemberships
    def memberships(options={})
      self.class.get_collection(
        self.links[:memberships], Cashboard::CompanyMembership, options
      )
    end
    
  end
end