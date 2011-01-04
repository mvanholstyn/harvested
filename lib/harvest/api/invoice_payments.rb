module Harvest
  module API
    class InvoicePayments < Base
      def all(invoice)
        response = request(:get, credentials, "/invoices/#{invoice.to_i}/payments")
        Harvest::InvoicePayment.parse(response.body)
      end
      
      def find(invoice, id)
        response = request(:get, credentials, "/invoices/#{invoice.to_i}/payments/#{id}")
        Harvest::InvoicePayment.parse(response.body, :single => true)
      end
      
      def create(invoice_payment)
        response = request(:post, credentials, "/invoices/#{invoice_payment.invoice_id}/payments", :body => invoice_payment.to_xml)
        id = response.headers["location"].first.match(/\/invoices\/(\d+)/)[1]
        find(invoice_payment.invoice_id, id)
      end
      
      def delete(invoice_payment)
        request(:delete, credentials, "/invoices/#{invoice_payment.invoice_id}/payments/#{invoice_payment.to_i}")
        invoice_payment.id
      end
    end
  end
end
