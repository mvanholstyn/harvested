module Harvest
  class HardyClient < Delegator
    def initialize(client, max_retries)
      super(client)
      @_sd_obj = @client = client
      @max_retries = max_retries
      (@client.public_methods - Object.public_instance_methods).each do |name|
        instance_eval <<-END
          def #{name}(*args)
            wrap_collection do
              @client.send('#{name}', *args)
            end
          end
        END
      end
    end
    
    def __getobj__; @_sd_obj; end
    def __setobj__(obj); @_sd_obj = obj; end
    
    def wrap_collection
      collection = yield
      HardyCollection.new(collection, self, @max_retries)
    end
    
    class HardyCollection < Delegator
      def initialize(collection, client, max_retries)
        super(collection)
        @_sd_obj = @collection = collection
        @client = client
        @max_retries = max_retries
        (@collection.public_methods - Object.public_instance_methods).each do |name|
          instance_eval <<-END
            def #{name}(*args)
              retry_rate_limits do
                @collection.send('#{name}', *args)
              end
            end
          END
        end
      end
      
      def __getobj__; @_sd_obj; end
      def __setobj__(obj); @_sd_obj = obj; end
      
      def retry_rate_limits
        retries = 0
        
        retry_func = lambda do |e|
          if retries < @max_retries
            retries += 1
            true
          else
            raise e
          end
        end
        
        begin
          yield
        rescue Harvest::RateLimited => e
          seconds = if e.response.headers["retry-after"]
            e.response.headers["retry-after"].first.to_i
          else
            16
          end
          sleep(seconds)
          retry
        rescue Harvest::Unavailable, Harvest::InformHarvest => e
          if would_retry = retry_func.call(e)
            # to try to reduce 'Harvest::Unavailable' errors
            sleep(16 * retries)
            retry
          end
        rescue Net::HTTPError, Net::HTTPFatalError => e
          retry if retry_func.call(e)
        rescue SystemCallError => e
          retry if e.is_a?(Errno::ECONNRESET) && retry_func.call(e)
        end
      end
    end
  end
end