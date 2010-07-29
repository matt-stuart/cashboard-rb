require File.dirname(__FILE__) + '/../test_helper.rb'

class ProjectTest < Test::Unit::TestCase  
  
  # CUSTOM ASSERTIONS ---------------------------------------------------------
  
  def assert_list_type(method, type)
    mock_sub_resource(
      Cashboard::Project.resource_name, 
      'line_items',
      'line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    prj = Cashboard::Project.list[0]
    collection = prj.send(method)
    assert collection.size > 0
    collection.each do |item|
      assert_kind_of Cashboard::LineItem, item
      assert_equal Cashboard::LineItem::TYPE_CODES[type], item.type_code.to_i
    end    
  end
  
  
  # TESTS ---------------------------------------------------------------------
  
  def test_list    
    projects = Cashboard::Project.list
    assert projects.size > 0
    projects.each do |prj|
      assert_kind_of Cashboard::Project, prj
    end
  end
  
  def test_create_success
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Project.resource_name}"),
      :status => ["201", "Created"],
      :body => Cashboard::Project.list[0].to_xml
    ) if MOCK_WEB_CONNECTIONS  
    
    client = Cashboard::ClientCompany.list[0]
    # Create random project name so even if not destroyed on 
    # a live connection we don't run into duplicate name validation errors.
    project_name = "Test project - " + generate_random_string
    assert_nothing_raised do
      project = Cashboard::Project.create(
        :name => project_name, 
        :client_id => client.id,
        :client_type => 'Company'
      )
      assert_kind_of Cashboard::Project, project
    end
  end
  
  def test_create_fail
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Project.resource_name}"),
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS  
    
    assert_raise Cashboard::BadRequest do
      prj = Cashboard::Project.create()
    end
  end
  
  def test_update_success
    prj = Cashboard::Project.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(prj.href), 
      :status => ["200", "Ok"],
      :body => prj.to_xml
    ) if MOCK_WEB_CONNECTIONS
    
    prj.name = 'Some new name'
    assert prj.update, "Project didn't save properly"
  end
  
  def test_update_fail
    prj = Cashboard::Project.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(prj.href), 
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    prj.name = 'Some new name'
    assert !prj.update, "Project saved when it shouldn't have"
  end
  
  def test_delete_success
    prj = Cashboard::Project.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(prj.href), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS

    assert prj.delete, "Project wasn't deleted."
  end
  
  def test_delete_fail
    prj = Cashboard::Project.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(prj.href), 
      :status => ["404", "Not found"]
    ) if MOCK_WEB_CONNECTIONS

    assert !prj.delete, "Project was deleted when it shouldn't have been."
  end
  
  def test_toggle_status_success
    prj = Cashboard::Project.list[0]
    assert_equal false, prj.is_active
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(prj.links[:toggle_status]), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS
    
    initial_status = prj.is_active
    
    assert prj.toggle_status
    assert true, prj.is_active
  end
  
  def test_toggle_status_failure
    prj = Cashboard::Project.list[0]
        
    FakeWeb.register_uri(
      :put, 
      url_with_auth(prj.links[:toggle_status]), 
      :status => ["401", "Unauthorized"]
    ) if MOCK_WEB_CONNECTIONS
    
    initial_status = prj.is_active
    
    assert !prj.toggle_status
    assert prj.is_active == initial_status
  end

  def test_employee_project_assignments
    mock_sub_resource(
      Cashboard::Project.resource_name, 
      'assigned_employees',
      'project_assignments'
    ) if MOCK_WEB_CONNECTIONS
    
    prj = Cashboard::Project.list[0]
    assignments = prj.employee_project_assignments
    assert assignments.size > 0
    assignments.each do |assn|
      assert_kind_of Cashboard::ProjectAssignment, assn
    end
  end
  
  def test_line_items
    mock_sub_resource(
      Cashboard::Project.resource_name, 
      'line_items',
      'line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    prj = Cashboard::Project.list[0]
    line_items = prj.line_items
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
  
  def test_href
    assert Cashboard::Project.list[0].href.include?(Cashboard::Base::CB_URL[:testing])
  end
  
end
