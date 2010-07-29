# Simple workflow that:
# * Creates a client company
# * Creates a project for that client
# * Creates a task for the project
# * Logs some time

require "../lib/cashboard"

Cashboard::Base.authenticate('your_subdomain', 'your_api_key')

# Create a new client
client = Cashboard::ClientCompany.create(
  :name => 'Bigtime Ventures'
)

# Create a new project for that client
project = Cashboard::Project.create(
  :name => 'Bigtime Web Redesign', 
  :client_id => client[:id],
  :client_type => 'Company'
)

# Create task for project
task = Cashboard::LineItem.create(
  :project_id => project[:id],
  :title => 'Graphic design'
)

# Track some time
time_entry = Cashboard::TimeEntry.create(
  :created_on => "04/11/2010", 
  :minutes => 8*60,
  :description => 'Trolled 4chan', 
  :task_id => task[:id]
)