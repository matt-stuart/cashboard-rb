module Cashboard
  class DocumentTemplate < Base
    element :content
    element :created_at, DateTime
    element :has_been_modified, Boolean
    element :is_default, Boolean
    element :name
    element :title
  end
end