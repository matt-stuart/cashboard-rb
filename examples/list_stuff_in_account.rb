# List various resources inside a Cashboard account
# and display them on the screen.

require "../lib/cashboard"

Cashboard::Base.authenticate('your_subdomain', 'your_api_key')

puts "Employees:"
Cashboard::Employee.list.each { |emp| puts emp.inspect }

puts "Client Companies:"
Cashboard::ClientCompany.list.each { |client| puts client.inspect }

puts "Projects:"
Cashboard::Project.list.each { |prj| puts prj.inspect }