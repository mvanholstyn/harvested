module Harvest
  # The model that contains information about a client
  #
  # == Fields
  # [+id+] (READONLY) the id of the client
  # [+name+] (REQUIRED) the name of the client
  # [+details+] the details of the client
  # [+currency+] what type of currency is associated with the client
  # [+currency_symbol+] what currency symbol is associated with the client
  # [+active?+] true|false on whether the client is active
  # [+highrise_id+] (READONLY) the highrise id associated with this client
  # [+update_at+] (READONLY) the last modification timestamp
  # TODO: Updated this documentation
  class Invoice < BaseModel
    include HappyMapper
  
    api_path '/invoices'
  
    element :id, Integer
    element :amount, Float
    element :due_amount, Float, :tag => "due-amount"
    element :discount_amount, Float, :tag => "discount-amount"
    element :due_at, Time, :tag => "due-at"
    element :due_at_human_format, String, :tag => "due-at-human-format"
    element :period_end, Date, :tag => "period-end"
    element :period_start, Date, :tag => "period-start"
    element :client_id, Integer, :tag => "client-id"
    element :retainer_id, Integer, :tag => "retainer-id"
    element :estimate_id, Integer, :tag => "estimate-id"
    element :recurring_invoice_id, Integer, :tag => "recurring-invoice-id"
    element :currency, String
    element :issued_at, Date, :tag => "issued-at"
    element :subject, String
    element :notes, String
    element :number, String
    element :purchase_order, String, :tag => "purchase-order"
    element :state, String
    element :discount, Float
    element :tax, Float
    element :tax2, Float
    element :tax_amount, Float, :tag => "tax-amount"
    element :tax2_amount, Float, :tag => "tax2-amount"
    element :updated_at, Time, :tag => "updated-at"
    element :created_at, Time, :tag => "created-at"
    element :csv_line_items, String, :tag => "csv-line-items"
  end
end