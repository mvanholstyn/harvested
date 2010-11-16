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
  class LineItem < BaseModel
    attr_accessor :kind, :description, :quantity, :unit_price, :amount, :taxed, :taxed2, :project_id
    
    def quantity=(quantity)
      @quantity = quantity.to_f
    end

    def unit_price=(unit_price)
      @unit_price = unit_price.to_f
    end

    def amount=(amount)
      @amount = amount.to_f
    end

    def taxed=(taxed)
      @taxed = (taxed == "true")
    end

    def taxed2=(taxed2)
      @taxed2 = (taxed2 == "true")
    end

    def project_id=(project_id)
      @project_id = project_id ? project_id.to_i : nil
    end
  end
end
