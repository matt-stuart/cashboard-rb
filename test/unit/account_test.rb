require File.dirname(__FILE__) + '/../test_helper.rb'

class AccountTest < Test::Unit::TestCase
  
  def test_create_success
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Account.resource_name}"),
      :status => ["201", "Created"],
      :body => get_xml_for_fixture('account')
    ) if MOCK_WEB_CONNECTIONS
    
    acct = Cashboard::Account.create({
      :subdomain => generate_random_string,
      :currency_type => 'USD',
      :date_format => 'mm_dd_yyyy',
      :owner => {
        :email_address => 'rza@wutang.com',
        :first_name => 'The',
        :last_name => 'Rza',
        :password => '36chambers'
      },
      :company => {
        :name => 'Wu Tang',
        :address => '1 Shogun Way',
        :city => 'Shaolin',
        :state => 'NY'
      }
    })
    
    assert_kind_of Cashboard::Struct, acct.owner
    assert_kind_of Cashboard::Struct, acct.company
    
    assert !acct.owner.api_key.blank?
  end
  
  def test_create_fail
    FakeWeb.register_uri(
      :post,
      url_with_auth("/#{Cashboard::Account.resource_name}"),
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    assert_raises Cashboard::BadRequest do
      Cashboard::Account.create()
    end
  end
  
  def test_update_success  
    acct = Cashboard::Account.new_from_url('/account')
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth("/#{Cashboard::Account.resource_name}"), 
      :status => ["200", "Ok"],
      :body => get_xml_for_fixture('account')
    ) if MOCK_WEB_CONNECTIONS
    
    acct.date_format = 'yyyy_mm_dd'
    assert acct.update, "Account didn't save properly"
  end
  
  def test_update_fail
    acct = Cashboard::Account.new_from_url('/account')
    
    FakeWeb.register_uri(
      :put, 
      url_with_auth("/#{Cashboard::Account.resource_name}"), 
      :status => ["400", "Bad Request"],
      :body => GENERIC_ERROR_XML
    ) if MOCK_WEB_CONNECTIONS
    
    acct.subdomain = ''
    assert !acct.update, "Account shouldn't have saved with blank subdomain"
  end
  
  def test_new_from_url
    acct = Cashboard::Account.new_from_url('/account')
    assert_kind_of Cashboard::Account, acct
    assert_kind_of Cashboard::Struct, acct.owner
    assert_kind_of Cashboard::Struct, acct.company
  end
  
end