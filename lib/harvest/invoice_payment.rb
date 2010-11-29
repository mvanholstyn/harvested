module Harvest
  class InvoicePayment < BaseModel
    include HappyMapper
    
    tag 'payment'
    element :id, Integer
    element :invoice_id, Integer, :tag => 'invoice-id'
    element :amount, Float
    element :created_at, Time, :tag => 'created-at'
    element :notes, String
    element :paid_at, Time, :tag => 'paid-at'
    element :recorded_by, String, :tag => 'recorded-by'
    element :recorded_by_email, String, :tag => 'recorded-by-email'
  end
end