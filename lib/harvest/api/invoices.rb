module Harvest
  module API
    class Invoices < Base
      api_model Harvest::Invoice

      include Harvest::Behavior::Crud

      def all(options = {})
        options = options.dup
        if options[:from]
          options[:from] = options[:from].strftime("%Y%m%d")
          if options[:to].nil?
            options[:to] = Date.new(2999, 12, 31)
          end
        end
        if options[:to]
          options[:to] = options[:to].strftime("%Y%m%d")
        end

        invoices, last_set, page = [], [], 1
        begin
          options[:page] = page
          response = request(:get, credentials, api_model.api_path, :query => options)
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