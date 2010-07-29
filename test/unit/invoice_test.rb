require File.dirname(__FILE__) + '/../test_helper.rb'

class InvoiceTest < Test::Unit::TestCase

  def test_list
    invoices = Cashboard::Invoice.list
    assert invoices.size > 0
    invoices.each do |inv|
      assert_kind_of Cashboard::Invoice, inv
    end
  end
  
  def test_create_success
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Invoice.resource_name}"),
      :status => ["201", "Created"],
      :body => Cashboard::Invoice.list[0].to_xml
    ) if MOCK_WEB_CONNECTIONS  
    
    client = Cashboard::ClientCompany.list[0]

    assert_nothing_raised do
      inv = Cashboard::Invoice.create(
        :client_id => client.id,
        :client_type => 'Company'
      )
      assert_kind_of Cashboard::Invoice, inv
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
    inv = Cashboard::Invoice.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(inv.href), 
      :status => ["200", "Ok"],
      :body => inv.to_xml
    ) if MOCK_WEB_CONNECTIONS
    
    inv.created_on = Date.today
    inv.due_date = Date.today + 1.week
    assert inv.update, "Invoice didn't save properly"
  end
  
  def test_update_fail
    inv = Cashboard::Invoice.list[0]
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(inv.href), 
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    inv.client_id = nil
    assert !inv.update, "Invoice saved when it shouldn't have"
  end
  
  def test_delete_success
    inv = Cashboard::Invoice.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(inv.href), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS

    assert inv.delete, "Invoice wasn't deleted."
  end
  
  def test_delete_fail
    inv = Cashboard::Invoice.list[0]
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(inv.href), 
      :status => ["404", "Not found"]
    ) if MOCK_WEB_CONNECTIONS

    assert !inv.delete, "Invoice was deleted when it shouldn't have been."
  end
  
  def test_line_items
    mock_sub_resource(
      Cashboard::Invoice.resource_name, 
      'line_items',
      'invoice_line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    inv = Cashboard::Invoice.list[0]
  
    line_items = inv.line_items
    assert line_items.size > 0
    
    line_items.each do |li|
      assert_kind_of Cashboard::InvoiceLineItem, li
    end
  end
  
  def mock_import_items_response
    FakeWeb.register_uri(
      :put, 
      get_sub_url_regexp(Cashboard::Invoice.resource_name, 'import_uninvoiced_items'), 
      :body => get_xml_for_fixture('invoice_line_items'),
      :status => ['200', 'OK']
    ) if MOCK_WEB_CONNECTIONS
  end
  
  def test_import_uninvoiced_items_no_options
    mock_import_items_response
    inv = Cashboard::Invoice.list[0]
    
    assert_nothing_raised do
      items = inv.import_uninvoiced_items
      assert items.size > 0
      items.each do |li|
        assert_kind_of Cashboard::InvoiceLineItem, li
      end
    end
  end
  
  def test_import_uninvoiced_items_with_projects
    mock_import_items_response
    inv = Cashboard::Invoice.list[0]
    
    inv.expects(:get_import_xml_options).with([12345], nil, nil)

    inv.import_uninvoiced_items([12345])
  end

  def test_get_import_xml_options_project_id
    xml_options = %Q\
      <?xml version="1.0" encoding="UTF-8"?>
      <projects>
        <id>12345</id>
      </projects>
      <start_date></start_date>
      <end_date></end_date>
    \
    inv = Cashboard::Invoice.list[0]

    opts = inv.get_import_xml_options([12345], nil, nil)

    assert_equal(
      xml_options.gsub(/\s/, ''),
      opts.gsub(/\s/, '')
    )
  end
  
  def test_get_import_xml_options_start_end_date
    d1 = Date.today-1.week
    d2 = Date.today
    xml_options = %Q\
      <?xml version="1.0" encoding="UTF-8"?>
      <projects>
      </projects>
      <start_date>#{d1.to_s}</start_date>
      <end_date>#{d2.to_s}</end_date>
    \
    inv = Cashboard::Invoice.list[0]

    opts = inv.get_import_xml_options(nil, d1, d2)

    assert_equal(
      xml_options.gsub(/\s/, ''),
      opts.gsub(/\s/, '')
    )
  end
  
end