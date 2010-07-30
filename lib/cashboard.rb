$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'typecasted_open_struct'
require 'rubygems'
require 'active_support'
require 'httparty'
require 'xmlsimple'
require 'builder'

module Cashboard
  # When reading the parsed hashes generated from parser we ignore these pairs.
  IGNORED_XML_KEYS = ['rel', 'read_only']
  
  class Struct < TypecastedOpenStruct
    # Since we're dealing with initializing from hashes with 'content'
    # keys we need to set properties based on those keys.
    #
    # Additionally, we do some magic to ignore attributes we don't care about.
    #
    # The basic concept is lifted from ostruct.rb
    def initialize(hash={})
      @table = {}
      return unless hash
      hash.each do |k,v|
        # Remove keys that aren't useful for our purposes.
        if v.class == Hash
          Cashboard::IGNORED_XML_KEYS.each {|ignored| v.delete(ignored)}
        end
        # Access items based on the 'content' key inside the hash.
        # Allows us to deal with all XML tags equally, even if the tags
        # have attributes or not.
        if v.class == Hash && v['content']
          @table[k.to_sym] = v['content']
        elsif v.class == Hash && v.empty?
          @table[k.to_sym] = nil
        else
          @table[k.to_sym] = v
        end
        new_ostruct_member(k)
      end
    end
  end
end

# Override HTTParty's XML parsing, which doesn't really work
# well for the output we receive.
class HTTParty::Parser
  protected
    def xml
      XmlSimple.xml_in(
        body, 
        'KeepRoot' => false, 
        # Force 'link' tags into an array always
        'ForceArray' => %w(link),
        # Force each item into a hash with a 'content' key for the tag value
        # If we don't do this random tag attributes can screw us up.
        'ForceContent' => true
      )
    end
end

# After we've defined some basics let's include 
# the Cashboard-rb API libraries

# Load base first or there's some issues with dependencies.
require 'cashboard/base'
require 'cashboard/behaviors/base'
require 'cashboard/behaviors/toggleable'
require 'cashboard/behaviors/lists_line_items'

library_files = Dir[File.join(File.dirname(__FILE__), 'cashboard/*.rb')]
library_files.each do |lib| 
  next if lib.include?('cashboard/base.rb')
  require lib
end