module Harvest
  module API
    class Invoices < Base
      api_model Harvest::Invoice

      include Harvest::Behavior::Crud

      # TODO: Document
      def line_items(invoice)
        invoice_with_line_items = find(invoice.id)
        line_items = FasterCSV.parse(invoice_with_line_items.csv_line_items, :headers => true)
        line_items.map do |line_item|
          Harvest::LineItem.new(line_item.to_hash)
        end
      end
    end
  end
end