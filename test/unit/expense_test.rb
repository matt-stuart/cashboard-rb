require File.dirname(__FILE__) + '/../test_helper.rb'

class ExpenseTest < Test::Unit::TestCase
  
  def test_list
    expenses = Cashboard::Expense.list
    assert expenses.size > 0
    expenses.each do |exp|
      assert_kind_of Cashboard::Expense, exp
      assert_kind_of DateTime, exp.created_on
      assert_kind_of Float, exp.amount
      assert exp.is_billable.class == TrueClass || exp.is_billable.class == FalseClass
    end
  end
  
end
