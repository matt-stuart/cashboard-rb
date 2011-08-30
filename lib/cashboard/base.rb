module Cashboard
  class Base < Cashboard::Struct
    include HTTParty
    
    if defined? TEST_ENVIRONMENT
      @@api_url = "http://apicashboard.i" 
    else
      @@api_url = "https://api.cashboardapp.com" 
    end
    
    base_uri @@api_url
    
    cattr_accessor :auth
    cattr_accessor :api_url
    
    # Stores id and url for resource when instantiated
    attr_accessor :id
    attr_accessor :href
      
    # Sets authentication credentials for all following requests.
    def self.authenticate(subdomain, api_key)
      @@auth = {:username => subdomain, :password => api_key}
    end
    
    # Clears authentication credentials.
    def self.clear_authentication
      @@auth = {}
    end
    
    # Initializes an object of this type by passing a known URL in.
    def self.new_from_url(url, options={})
      response = get(url, merge_options(options))
      check_status_code(response)
      return self.new(response[resource_name])        
    end
    
    # Lists all items for a resource.
    #
    # Returns array of objects of the type listed.
    # raises error if something goes wrong.
    def self.list(options={})
      self.get_collection("/#{resource_name}", self, options)
    end
    
    # Creates a resource.
    #
    # Returns object of type created if success, or raise error
    # if something went wrong.
    #
    # Allows you to pass in a hash to create without naming it.
    #
    # Example:
    #   te = Cashboard::TimeEntry.create({
    #     :minutes => 60, :project_id => 12345
    #   })
    def self.create(params={}, options={})
      options = merge_options(options)
      options.merge!({:body => self.new(params).to_xml})
      response = post("/#{resource_name}", options)
      check_status_code(response)
      return self.new(response.parsed_response)
    end
    
    # INSTANCE METHODS ========================================================
        
    # Override OpenStruct's implementation of the id property.
    # This allows us to set and retrieve id's for our corresponding
    # Cashboard items.
    def id; @table[:id]; end
    
    # Returns hash of HTTP links for this object, returned as <link>
    # tags in the XML.
    #
    # These links determine what you can do with an object, as defined
    # by the Cashboard API.
    def links
      @links ||= begin
        links = HashWithIndifferentAccess.new
        self.link.each do |link|
          links[link['rel']] = link['href']
        end
        links
      end
    end
    
    # The unique HTTP URL that is used to access an object.
    def href; self.links[:self]; end

    # Updates the object on server, after attributes have been set.
    # Returns boolean if successful
    #
    # Example:
    #   te = Cashboard::TimeEntry.new_from_url(time_entry_url)
    #   te.minutes = 60
    #   update_success = te.update
    def update
      options = self.class.merge_options()
      options.merge!({:body => self.to_xml})
      response = self.class.put(self.href, options)
      begin 
        self.class.check_status_code(response)
      rescue
        return false
      end
      return true
    end
  
    # Destroys Cashboard object on the server.
    # Returns boolean upon success.
    def delete
      options = self.class.merge_options()
      response = self.class.delete(self.href, options)
      begin 
        self.class.check_status_code(response)
      rescue
        return false
      end
      return true
    end
    
    # Utilizes ActiveSupport to turn our objects into XML
    # that we can pass back to the server.
    #
    # General concept stolen from Rails CoreExtensions::Hash::Conversions
    def to_xml(options={})
      options[:indent] ||= 2
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]

      obj_name = self.class.resource_name.singularize
      
      # Turn our OpenStruct attributes into a hash we can export to XML
      obj_attrs = self.marshal_dump
      
      xml.tag!(obj_name) do
        obj_attrs.each do |key,value|
          next if key.to_sym == :link # Don't feed back links to server
          case value
            when ::Hash
              value.to_xml(
                options.merge({ 
                  :root => key, 
                  :skip_instruct => true 
                })
              )
            when ::Array
              value.to_xml(
                options.merge({ 
                  :root => key, 
                  :children => key.to_s.singularize, 
                  :skip_instruct => true
                })
              )
            else
              xml.tag!(key, value)
          end
        end
      end
    end
    
    protected
      # No-configuration way to grab the resource name we're operatingo on.
      # As long as we stick to a proper naming convention we have 
      # less shit to type out.
      def self.resource_name
        name.demodulize.tableize
      end
   
      # Lists a collection of things from the API and returns as
      # an array of 'klass_to_return' items.
      def self.get_collection(url, klass_to_return, options={})
        response = get(url, merge_options(options))
        check_status_code(response)
        collection = response.parsed_response[klass_to_return.resource_name.singularize]
        return unless collection
        collection = [collection] unless collection.kind_of?(Array)
        collection.map do |h| 
          klass_to_return.new(h)
        end
      end
    
      # Ensures authentication and headers are set as options 
      # on each request.
      def self.merge_options(options={})
        options.merge!(
          {
            :basic_auth => @@auth, 
            :format => :xml,
            :headers => {
              'content-type' => 'application/xml'
            }
          }
        )
      end
      
      # Checks http status code and raises exception if it's not in 
      # the realm of acceptable statuses.
      def self.check_status_code(response)
        case response.code
          when 200, 201
            return # Good status codes
          when 400
            raise Cashboard::BadRequest.new(response)
          when 401
            raise Cashboard::Unauthorized.new(response)
          when 402
            raise Cashboard::PaymentRequired.new(response)
          when 403
            raise Cashboard::Forbidden.new(response)
          when 404
            raise Cashboard::NotFound.new(response)
          when 500
            raise Cashboard::ServerError.new(response)
          when 502
            raise Cashboard::Unavailable.new(response)
          when 503
            raise Cashboard::RateLimited.new(response)
          else
            raise Cashboard::HTTPError.new(response)
        end
      end
  
  end # Cashboard::Base
end