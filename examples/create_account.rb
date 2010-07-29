# Shows a simple method to create an account via API
# then connect and list resources for that account.

require "../lib/cashboard"

# Create a new account from the API
# Creating an account doesn't require an authorized connection.
begin
  acct = Cashboard::Account.create({
    :subdomain => 'WuTang',
    :currency_type => 'USD',
    :date_format => 'mm_dd_yyyy',
    :owner => {
      :email_address => 'rza@wutang.com',
      :first_name => 'The',
      :last_name => 'Rza',
      :password => '36chambers'
    },
    :company => {
      :name => 'Wu Tang',
      :address => '1 Shogun Way',
      :city => 'Shaolin',
      :state => 'NY'
    }
  })
rescue Cashboard::BadRequest => e
  puts "Account creation failure"
  puts e.errors.inspect
end

puts acct.inspect

# Connect to account after we've created it
Cashboard::Base.authenticate(acct.subdomain, acct.owner[:api_key])

# List all projects in the account (should be 1 by default)
puts "Projects:"
Cashboard::Project.list.each {|prj| puts prj.inspect }