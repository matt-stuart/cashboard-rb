require 'ostruct'
require 'date'
require 'time'

class Boolean; end

# A class to provide a quick and dirty way to typecast attributes
# that we specify, while silently setting the rest.
#
# Allows us to specify important attributes, but doesn't force us to
# update schema in order to deal with unexpected new properties.
#
#
# Example:
# 
#   class MyFoo < TypecastedOpenStruct
#     element :true_false_thing, Boolean
#     element :amount, Float
#  end
class TypecastedOpenStruct < OpenStruct
  @@elements = {}
  
  def self.element(name, attr_type=String, options={})
    element = Element.new(name, attr_type, options)
    @@elements[name] = element
    
    # Define getter to attr_typecast proper value
    define_method(element.method_name) do
      self.class.attr_typecast(
        @table[element.method_name.to_sym], 
        @@elements[name].attr_type
      )
    end
  end
  
  # Lifted from HappyMapper. Thanks! :)
  def self.attr_typecast(value, attr_type)
    return value if value.kind_of?(attr_type) || value.nil?
    begin
      if    attr_type == String    then value.to_s
      elsif attr_type == Float     then value.to_f
      elsif attr_type == Time      then Time.parse(value.to_s)
      elsif attr_type == Date      then Date.parse(value.to_s)
      elsif attr_type == DateTime  then DateTime.parse(value.to_s)
      elsif attr_type == Boolean   then ['true', 't', '1'].include?(value.to_s.downcase)
      elsif attr_type == Integer
        # ganked from datamapper
        value_to_i = value.to_i
        if value_to_i == 0 && value != '0'
          value_to_s = value.to_s
          begin
            Integer(value_to_s =~ /^(\d+)/ ? $1 : value_to_s)
          rescue ArgumentError
            nil
          end
        else
          value_to_i
        end
      else
        value
      end
    rescue
      value
    end
  end
  
  class Element
    attr_types = [String, Float, Time, Date, DateTime, Integer, Boolean]
  
    attr_accessor :name, :attr_type, :options, :namespace
  
    def initialize(name, attr_type=String, options={})
      self.name = name.to_s
      self.attr_type = attr_type
      self.options = options
    end
    
    def method_name
      @method_name ||= name.tr('-', '_')
    end    
  end
end