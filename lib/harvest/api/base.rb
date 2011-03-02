module Harvest
  module API
    class Base
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
          puts '---[Harvest] ' + path
          params = {}
          params[:path] = path
          params[:options] = options
          params[:method] = method
          response = HTTParty.send(method, "#{credentials.host}#{path}", :query => options[:query], :body => options[:body], :headers => {"Accept" => "application/xml", "Content-Type" => "application/xml; charset=utf-8", "Authorization" => "Basic #{credentials.basic_auth}", "User-Agent" => "Harvestable/#{Harvest::VERSION}"}.update(options[:headers] || {}), :format => :plain)
          puts '---[Harvest] -- ' + response.code.to_s
          params[:response] = response.inspect.to_s
          case response.code
          when 200..201
            response
          when 400
            raise Harvest::BadRequest.new(response, params)
          when 404
            if Harvest::ModuleDisabled.module_disabled?(path)
              raise Harvest::ModuleDisabled.build(path, response, params)
            else
              raise Harvest::NotFound.new(response, params)
            end
          when 500
            raise Harvest::ServerError.new(response, params)
          when 502
            raise Harvest::Unavailable.new(response, params)
          when 503
            raise Harvest::RateLimited.new(response, params)
          else
            raise Harvest::InformHarvest.new(response, params)
          end
        end
    end
  end
end
