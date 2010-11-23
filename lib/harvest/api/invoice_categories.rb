module Harvest
  module API
    class InvoiceCategories < Base
      api_model Harvest::InvoiceCategory
    
      include Harvest::Behavior::Crud
    end
  end
end