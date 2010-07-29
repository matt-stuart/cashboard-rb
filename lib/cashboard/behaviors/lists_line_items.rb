# Standard interface to list associated LineItems
# for Projects and Estimates
module Cashboard::Behaviors::ListsLineItems
  # Returns all associated LineItems regardless of type
  def line_items(options={})
    self.class.get_collection(
      self.links[:line_items], Cashboard::LineItem, options
    )
  end

  # LineItems of type 'task'
  def tasks
    self.filter_line_items_by :task
  end

  # LineItems of type 'product'
  def products
    self.filter_line_items_by :product
  end

  # LineItems of type 'custom'
  def custom_items
    self.filter_line_items_by :custom
  end
  
  protected
    def filter_line_items_by(type)
      self.line_items.reject do |li| 
        li.type_code != Cashboard::LineItem::TYPE_CODES[type]
      end
    end
end