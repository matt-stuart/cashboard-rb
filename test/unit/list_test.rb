require File.dirname(__FILE__) + '/../test_helper.rb'

class ListTest < Test::Unit::TestCase

  def test_list
    # Populate the many xml
    mock_simple_list_requests_for_resource("lists", "list/many")
    
    list = Cashboard::List.list
    assert list.size > 0
    assert_kind_of Array, list
    list.each do |l|
      assert_kind_of Cashboard::List, l
    end
  end 
  
  def test_list_empty
    # Populate the many xml
    mock_simple_list_requests_for_resource("lists", "list/empty")
    
    list = Cashboard::List.list
    assert list.nil?
  end    
  
  def test_list_single
    # Populate the many xml
    mock_simple_list_requests_for_resource("lists", "list/single")
    
    list = Cashboard::List.list
    assert list.size == 1
    assert_kind_of Array, list
    list.each do |l|
      assert_kind_of Cashboard::List, l
    end
  end    
end