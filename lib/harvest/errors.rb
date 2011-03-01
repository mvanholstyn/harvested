module Harvest
  class InvalidCredentials < StandardError; end

  class HTTPError < StandardError
    attr_reader :response
    attr_reader :params

    def initialize(response, params = {})
      @response = response
      @params = params
      super(response)
    end

    def to_s
      hint = response.headers["hint"].nil? ? nil : response.headers["hint"].first
      "#{self.class.to_s} : #{response.code}#{" - #{hint}" if hint}"
    end
  end

  class RateLimited < HTTPError; end
  class NotFound < HTTPError; end

  module ModuleDisabled
    MODULE_PATHS = /^(\/invoices|\/invoice_item_categories|\/expenses|\/expense_categories)/

    class Invoices < HTTPError; end
    class ExpenseTracking < HTTPError; end

    def self.build(path, response, params)
      if path.match(/^(\/invoices|\/invoice_item_categories)/ )
        exception_class = ModuleDisabled::Invoices
      elsif path.match(/^(\/expenses|\/expense_categories)/ )
        exception_class = ModuleDisabled::ExpenseTracking
      end

      return exception_class.new(response, params)
    end

    def self.module_disabled?(path)
      if MODULE_PATHS.match(path)
        return true
      else
        return false
      end
    end
  end

  class Unavailable < HTTPError; end
  class InformHarvest < HTTPError; end
  class BadRequest < HTTPError; end
  class ServerError < HTTPError; end
end