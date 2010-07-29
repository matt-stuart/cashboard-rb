module Cashboard
  class Employee < Base
    STATUS_CODES = {
      :employee => 0,
      :administrator => 2
    }
    
    element :api_key, String
    element :last_login, DateTime
    element :login_count, Integer
    element :address
    element :address2
    element :city
    element :country_code
    element :custom_1
    element :custom_2
    element :custom_3
    element :email_address
    element :employee_status_code, Integer
    element :first_name
    element :last_name
    element :notes
    element :password
    element :state
    element :telephone
    element :url
    element :zip
  end
end