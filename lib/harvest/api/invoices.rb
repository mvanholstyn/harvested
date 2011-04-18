module Harvest
  module API
    class Invoices < Base
      api_model Harvest::Invoice

      include Harvest::Behavior::Crud

      def all
        invoices, last_set, page = [], [], 1
        begin
          response = request(:get, credentials, api_model.api_path + "?page=#{page}")
          last_set = api_model.parse(response.body)
          invoices += last_set
          page += 1
        end until last_set.length != 50
        invoices
      end

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