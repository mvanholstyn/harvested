module Harvest
  module API
    class Base
      MODULE_PATHS = /^(\/invoices|\/expenses|\/expense_categories)/

      attr_reader :credentials
      
      def initialize(credentials)
        @credentials = credentials
      end
      
      class << self
        def api_model(klass)
          class_eval <<-END
            def api_model
              #{klass}
            end
          END
        end
      end
      
      protected
        def request(method, credentials, path, options = {})
          puts '---[harvest] ' + path
          response = HTTParty.send(method, "#{credentials.host}#{path}", :query => options[:query], :body => options[:body], :headers => {"Accept" => "application/xml", "Content-Type" => "application/xml; charset=utf-8", "Authorization" => "Basic #{credentials.basic_auth}", "User-Agent" => "Harvestable/#{Harvest::VERSION}"}.update(options[:headers] || {}), :format => :plain)
          puts '---[harvest] -- ' + response.code.to_s

          case response.code
          when 200..201
            response
          when 400
            raise Harvest::BadRequest.new(response)
          when 404
            if MODULE_PATHS.match(path)
              raise Harvest::ModuleDisabled.new(response)
            else
              raise Harvest::NotFound.new(response)
            end
          when 500
            raise Harvest::ServerError.new(response)
          when 502
            raise Harvest::Unavailable.new(response)
          when 503
            raise Harvest::RateLimited.new(response)
          else
            raise Harvest::InformHarvest.new(response)
          end
        end
    end
  end
end