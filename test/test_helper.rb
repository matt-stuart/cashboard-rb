TEST_ENVIRONMENT = true

require File.dirname(__FILE__) + '/../lib/cashboard'
require 'test/unit'
require 'yaml'
require 'rubygems'
require 'mocha'
require 'fakeweb'

FIXTURE_PATH = File.join(File.dirname(__FILE__), 'fixtures')
GENERIC_ERROR_XML = %Q\
  <errors><error field="name">Is required</error></errors>
\

# Useful for turning off mocks in test suites globally.
#
# If you set this to FALSE the requests will go over the wire
# and attempt to conenct to the account specified in 
# fixtures/cashboard_credentials.yml.
MOCK_WEB_CONNECTIONS = true

class Test::Unit::TestCase
  
  # Loads auth credentials from a fixture file.
  # NOT included in the base distribution. You need to create one
  # if you wish to test, using the example file.
  def setup    
    @auth = YAML::load(File.open(File.join(
        File.dirname(__FILE__), 
        'fixtures/cashboard_credentials.yml'
      ))
    )
    
    Cashboard::Base.authenticate(
      @auth['test_account']['subdomain'], 
      @auth['test_account']['api_key']
    )
    
    if MOCK_WEB_CONNECTIONS
      FakeWeb.allow_net_connect = false
      mock_simple_list_requests
    end
  end
  
  # Generates a random alphanumeric string
  def generate_random_string(size=10)
    chars = (('a'..'z').to_a + ('0'..'9').to_a)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  # Returns XML string to be used as body of HTTP request.
  # Useful as a shortcut from mocking requests in other tests.
  def get_xml_for_fixture(resource)
    file_name = File.join(FIXTURE_PATH, "#{resource}.xml") 
    return File.open(file_name, 'rb') { |f| f.read }
  end
  
  # Returns a regular expression that matches multiple fakeweb requests
  # for sub resource URLS...like http://apicashboard.i/projects/{project-id}/line_items
  def get_sub_url_regexp(resource, sub_resource)
    url_no_prefix = Cashboard::Base.api_url.gsub(%r|https*\://|, '')
    %r|#{url_no_prefix}/#{resource}/.*/#{sub_resource}|
  end
  
  # Returns the base API url with authentication credentials applied.
  # Useful for fakeweb, which will be passed the auth string 
  # by HTTParty automatically.
  #
  # If a URL is passed in, it will be deconstructed and auth credentials
  # added in place. Useful for mocking fakeweb requests for delete/update/etc.
  def url_with_auth(passed_url=nil)
    prefix_pattern = %r|https*\://|
    url_prefix = Cashboard::Base.api_url.match(prefix_pattern)[0]
    url  = url_prefix
    url << "#{@auth['test_account']['subdomain']}:"
    url << "#{@auth['test_account']['api_key']}@"
    url << Cashboard::Base.api_url.gsub(prefix_pattern, '')
    # Replace base url with our auth'd one.
    if passed_url
      url << passed_url.gsub(/.*#{Cashboard::Base.api_url}/, '')
    end
    return url    
  end
  
  # MOCKS ---------------------------------------------------------------------
  
  # Fakes all list requests and returns proper xml response based
  # on fixtures in our test directory.
  def mock_simple_list_requests
    Dir[File.join(FIXTURE_PATH, '/*.xml')].each do |file_name| 
      resource_name = file_name.match(/.*\/(.*)\.xml/)[1]

      FakeWeb.register_uri(
        :get, 
        url_with_auth + "/#{resource_name}", 
        :body => File.open(file_name, 'rb') { |f| f.read },
        :content_type => "application/xml"
      )
    end
  end
  
  # Registers a resource and associates it with the specified fixture_file
  def mock_simple_list_requests_for_resource(resource, fixture_file=nil)
    FakeWeb.register_uri(
      :get, 
      url_with_auth + "/#{resource}", 
      :body => get_xml_for_fixture(fixture_file || resource),
      :content_type => "application/xml"
    )
  end
  
  # Fakes request for a sub resource.
  def mock_sub_resource(resource, sub_resource, fixture_name, status=['200', 'OK'])
    FakeWeb.register_uri(
      :get, 
      get_sub_url_regexp(resource, sub_resource), 
      :body => get_xml_for_fixture(fixture_name),
      :status => status
    )
  end
  
end

# Include the test only classes
library_files = Dir[File.join(File.dirname(__FILE__), 'cashboard/*.rb')]
library_files.each do |lib| 
  next if lib.include?('cashboard/base.rb')
  require lib
end