require File.dirname(__FILE__) + '/../test_helper.rb'

class TimeEntryTest < Test::Unit::TestCase

  def find_uninvoiced_entry
    entries = Cashboard::TimeEntry.list
    @te = entries.find {|e| e.has_been_invoiced? == false }
  end

  # TESTS ---------------------------------------------------------------------
  
  def test_list
    time_entries = Cashboard::TimeEntry.list
    assert time_entries.size > 0
    time_entries.each do |te|
      assert_kind_of Cashboard::TimeEntry, te
    end
  end
  
  def test_create_success
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::TimeEntry.resource_name}"),
      :status => ["201", "Created"],
      :body => Cashboard::TimeEntry.list[0].to_xml
    ) if MOCK_WEB_CONNECTIONS
    
    # Fake line item list
    mock_sub_resource(
      Cashboard::Project.resource_name, 
      'line_items',
      'line_items'
    ) if MOCK_WEB_CONNECTIONS
    
    task = Cashboard::Project.list[0].tasks[0]
    
    assert_nothing_raised do
      @entry = Cashboard::TimeEntry.create(
        :description => "Testing time entries from API wrapper",
        :line_item_id => task.id
      )
    end
  end
  
  def test_create_fail
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::TimeEntry.resource_name}"),
      :status => ["400", "Bad Request"],
      :body => Cashboard::TimeEntry.list[0].to_xml
    ) if MOCK_WEB_CONNECTIONS  
    
    assert_raise Cashboard::BadRequest do
      @entry = Cashboard::TimeEntry.create(
        :description => "No line item specified will make the API puke"
      )
    end
  end
  
  def test_update_success
    find_uninvoiced_entry
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(@te.href), 
      :status => ["200", "Ok"],
      :body => @te.to_xml
    ) if MOCK_WEB_CONNECTIONS
    
    @te.description = 'Twkin'
    assert @te.update, "Entry didn't save properly"
  end
  
  def test_update_fail
    find_uninvoiced_entry
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(@te.href), 
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    
    @te.line_item_id = nil
    assert !@te.update, "Entry saved when it shouldn't have"
  end
  
  def test_delete_success
    find_uninvoiced_entry
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(@te.href), 
      :status => ["200", "Ok"]
    ) if MOCK_WEB_CONNECTIONS

    assert @te.delete, "Time entry wasn't deleted."
  end
  
  def test_delete_fail
    find_uninvoiced_entry
    
    @te.href = "http://#{Cashboard::Base::CB_URL[:testing]}/time_entries/12345"
    
    FakeWeb.register_uri(
      :delete, 
      url_with_auth(@te.href), 
      :status => ["404", "Not found"]
    ) if MOCK_WEB_CONNECTIONS

    assert !@te.delete, "Entry shouldn't have been found"
  end
  
  def test_has_been_invoiced
    entries = Cashboard::TimeEntry.list

    te = entries.find{|e| e.description == "Not billed yet." }
    assert_kind_of Cashboard::TimeEntry, te
    
    assert te.invoice_line_item_id.blank?, "Invoice line item wasn't blank when should have been"
    assert !te.has_been_invoiced?
  end

  def test_toggle_timer_success_with_stopped_timer
    find_uninvoiced_entry
    assert_equal false, @te.is_running
    assert_nil @te.timer_started_at
    
    # Mocks a "toggled" timer from stop to start.
    # Also includes a faked "stopped" timer that was returned with the data,
    # as the API would do.
    toggled_timer_xml = %Q\
      <time_entry>
        <link rel="toggle_timer" href="http://apicashboard.i/time_entries/800720104/toggle_timer"/>
        <link rel="self" href="http://apicashboard.i/time_entries/800720104"/>
        <id>800720104</id>
        <created_on>2007-04-05 01:26:43</created_on>
        <description>Not billed yet.</description>
        <invoice_line_item_id read_only="true"></invoice_line_item_id>
        <is_billable>false</is_billable>
        <line_item_id>5568311</line_item_id>
        <minutes>30</minutes>
        <minutes_with_timer read_only="true">30</minutes_with_timer>
        <person_id>215816037</person_id>
        
        <is_running read_only="true">true</is_running>
        <timer_started_at read_only="true">2010-01-01 05:55:55</timer_started_at>
        <stopped_timer>
          <href>http://url_of_stopped_entry</href>
          <id>123456</id>
          <minutes>30</minutes>
        </stopped_timer>
        
      </time_entry>
    \
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(@te.links[:toggle_timer]), 
      :status => ["200", "Ok"],
      :body => toggled_timer_xml
    ) if MOCK_WEB_CONNECTIONS
    
    stopped_timer = @te.toggle_timer
    assert true, @te.is_running
    assert_kind_of DateTime, @te.timer_started_at
    assert_kind_of Cashboard::Struct, stopped_timer
  end
  
  def test_toggle_timer_success_without_stopped_timer
    find_uninvoiced_entry
    assert_equal false, @te.is_running
    assert_nil @te.timer_started_at
    
    # Mocks a "toggled" timer from stop to start.
    # Also includes a faked "stopped" timer that was returned with the data,
    # as the API would do.
    toggled_timer_xml = %Q\
      <time_entry>
        <link rel="toggle_timer" href="http://apicashboard.i/time_entries/800720104/toggle_timer"/>
        <link rel="self" href="http://apicashboard.i/time_entries/800720104"/>
        <id>800720104</id>
        <created_on>2007-04-05 01:26:43</created_on>
        <description>Not billed yet.</description>
        <invoice_line_item_id read_only="true"></invoice_line_item_id>
        <is_billable>false</is_billable>
        <line_item_id>5568311</line_item_id>
        <minutes>30</minutes>
        <minutes_with_timer read_only="true">30</minutes_with_timer>
        <person_id>215816037</person_id>
        
        <is_running read_only="true">true</is_running>
        <timer_started_at read_only="true">2010-01-01 05:55:55</timer_started_at>
      </time_entry>
    \
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth(@te.links[:toggle_timer]), 
      :status => ["200", "Ok"],
      :body => toggled_timer_xml
    ) if MOCK_WEB_CONNECTIONS
    
    stopped_timer = @te.toggle_timer
    assert true, @te.is_running
    assert_kind_of DateTime, @te.timer_started_at
    assert_nil stopped_timer
  end
  
  def test_toggle_status_failure
    find_uninvoiced_entry
        
    FakeWeb.register_uri(
      :put, 
      url_with_auth(@te.links[:toggle_timer]), 
      :status => ["403", "Forbidden"]
    ) if MOCK_WEB_CONNECTIONS
    
    assert_raises Cashboard::Forbidden do 
      @te.toggle_timer
    end
  end
  
end
