require "../lib/cashboard"

Cashboard::Base.authenticate('your_subdomain', 'your_api_key')

# Grab reference to first task in account
prj = Cashboard::Project.list[0]

# Grab reference to first task
task = prj.tasks[0]

puts "Creating a time entry for..."
puts "  Project: #{prj.name}"
puts "  Task   : #{task.title}\n\n"

# Create a time entry for it
te = Cashboard::TimeEntry.create({
  :line_item_id => task.id,
  :minutes => 60,
  :description => "Doin work!"
})

# Show our handy work
puts te.inspect

# Remove it
if te.delete == true
  puts "\nTime entry has been destroyed"
else
  puts "\nTime entry could not be destroyed"
end
