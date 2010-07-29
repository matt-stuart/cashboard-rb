# Runs all unit tests for the library
require 'test/unit'
Dir[File.join(File.dirname(__FILE__), 'unit/*.rb')].each {|lib| require lib}