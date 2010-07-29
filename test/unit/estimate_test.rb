require File.dirname(__FILE__) + '/../test_helper.rb'

class EstimateTest < Test::Unit::TestCase
  
  # CUSTOM ASSERTIONS ---------------------------------------------------------
  
  def assert_list_type(method, type)
    mock_sub_resource(
      Cashboard::Estimate.resource_name, 
      'line_items',
      'line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    est = Cashboard::Estimate.list[0]
    collection = est.send(method)
    assert collection.size > 0
    collection.each do |item|
      assert_kind_of Cashboard::LineItem, item
      assert_equal Cashboard::LineItem::TYPE_CODES[type], item.type_code.to_i
    end    
  end

  
  # TESTS ---------------------------------------------------------------------
  
  def test_list
    estimates = Cashboard::Estimate.list
    assert estimates.size > 0
    estimates.each do |est|
      assert_kind_of Cashboard::Estimate, est
    end
  end
  
  def test_create
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Estimate.resource_name}"),
      :status => ["201", "Created"],
      :body => Cashboard::Estimate.list[0].to_xml
    ) if MOCK_WEB_CONNECTIONS  
    
    client = Cashboard::ClientCompany.list[0]
    
    # Create random estimate name so even if not destroyed on 
    # a live connection we don't run into duplicate name validation errors.
    est_name = "Test estimate - " + generate_random_string
    assert_nothing_raised do
      estimate = Cashboard::Estimate.create(
        :name => est_name, 
        :client_id => client.id,
        :client_type => 'Company'
      )
    end
  end
  
  def test_update_success
    est = Cashboard::Estimate.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(est.href), 
      :status => ["200", "Ok"],
      :body => est.to_xml
    ) if MOCK_WEB_CONNECTIONS
    
    est.name = 'Some new name'
    assert est.update, "Estimate didn't save properly"
  end
  
  def test_update_fail
    est = Cashboard::Estimate.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(est.href), 
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    est.name = 'Some new name'
    assert !est.update, "Estimate saved when it shouldn't have"
  end
  
  def test_delete_success
    est = Cashboard::Estimate.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(est.href), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS

    assert est.delete, "Estimate wasn't deleted."
  end
  
  def test_delete_fail
    est = Cashboard::Estimate.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(est.href), 
      :status => ["404", "Not found"]
    ) if MOCK_WEB_CONNECTIONS

    assert !est.delete, "Estimate was deleted when it shouldn't have been."
  end
  
  def test_toggle_status_success
    est = Cashboard::Estimate.list[0]
    assert_equal false, est.is_active
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(est.links[:toggle_status]), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS
    
    initial_status = est.is_active
    
    assert est.toggle_status
    assert true, est.is_active
  end
  
  def test_toggle_status_failure
    est = Cashboard::Estimate.list[0]
        
    FakeWeb.register_uri(
      :put, 
      url_with_auth(est.links[:toggle_status]), 
      :status => ["401", "Unauthorized"]
    ) if MOCK_WEB_CONNECTIONS
    
    initial_status = est.is_active
    
    assert !est.toggle_status
    assert est.is_active == initial_status
  end
  
  def test_line_items
    mock_sub_resource(
      Cashboard::Project.resource_name, 
      'line_items',
      'line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    est = Cashboard::Estimate.list[0]
    line_items = est.line_items
    assert line_items.size > 0
    line_items.each do |li|
      assert_kind_of Cashboard::LineItem, li
    end
  end
  
  def test_tasks
    assert_list_type :tasks, :task
  end
  
  def test_products
    assert_list_type :products, :product
  end
  
  def test_custom_items
    assert_list_type :custom_items, :custom
  end
  
end
