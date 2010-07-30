require 'rubygems'
require 'rake'

require File.dirname(__FILE__) + "/lib/cashboard"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cashboard"
    gem.summary = "Ruby wrapper library for the Cashboard API "
    gem.description = "For more information see the homepage. Support and discussion can be found on the Cashboard forum (http://forum.getcashboard.com/)"
    gem.email = "support@getcashboard.com"
    gem.homepage = "http://github.com/subimage/cashboard-rb"
    gem.authors = ["Subimage LLC"]
    gem.version = Cashboard::VERSION
    gem.add_development_dependency('mocha', '>= 0.9.8')
    gem.add_development_dependency('fakeweb', '>= 1.2.8')
    gem.add_dependency('activesupport', '>= 2.3.5')
    gem.add_dependency('httparty', '>= 0.6.1')
    gem.add_dependency('xml-simple', '>= 1.0.12')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end