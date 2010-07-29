require File.dirname(__FILE__) + '/../test_helper.rb'

class DocumentTemplateTest < Test::Unit::TestCase

  def test_list
    templates = Cashboard::DocumentTemplate.list
    assert templates.size > 0
    templates.each do |dt|
      assert_kind_of Cashboard::DocumentTemplate, dt
    end
  end

  def test_href
    tmpl = Cashboard::DocumentTemplate.list[0]
    assert_kind_of String, tmpl.href
  end

end