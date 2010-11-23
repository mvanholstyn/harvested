module Harvest
  
  # The model that contains information about a task
  #
  # == Fields
  # [+id+] (READONLY) the id of the task
  # [+name+] (REQUIRED) the name of the task
  # [+billable+] whether the task is billable by default
  # [+deactivated+] whether the task is deactivated
  # [+hourly_rate+] what the default hourly rate for the task is
  # [+default?+] whether to add this task to new projects by default
  # TODO: Document
  class InvoiceCategory < BaseModel
    include HappyMapper
  
    tag 'invoice-item-category'
    api_path '/invoice_item_categories'
  
    element :id, Integer
    element :name, String
    element :use_as_expense, Boolean, :tag => 'use-as-expense'
    element :use_as_service, Boolean, :tag => 'use-as-service'

    alias_method :use_as_expense?, :use_as_expense
    alias_method :use_as_service?, :use_as_service
  end
end