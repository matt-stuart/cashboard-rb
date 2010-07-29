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
    %r|#{Cashboard::Base::CB_URL[:testing]}/#{resource}/.*/#{sub_resource}|
  end
  
  # Returns the base API url with authentication credentials applied.
  # Useful for fakeweb, which will be passed the auth string 
  # by HTTParty automatically.
  #
  # If a URL is passed in, it will be deconstructed and auth credentials
  # added in place. Useful for mocking fakeweb requests for delete/update/etc.
  def url_with_auth(passed_url=nil)
    url  = "http://#{@auth['test_account']['subdomain']}:"
    url << "#{@auth['test_account']['api_key']}@"
    url << Cashboard::Base::CB_URL[:testing]
    # Replace base url with our auth'd one.
    if passed_url
      url << passed_url.gsub(/.*#{Cashboard::Base::CB_URL[:testing]}/, '')
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