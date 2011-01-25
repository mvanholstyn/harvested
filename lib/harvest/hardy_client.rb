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
      attr_accessor :sleep_increment

      def initialize(collection, client, max_retries, sleep_increment=16)
        super(collection)
        @sleep_increment = sleep_increment
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
        rescue Harvest::RateLimited, Harvest::Unavailable => e
          if would_retry = retry_func.call(e)
            seconds = if e.response.headers["retry-after"]
              e.response.headers["retry-after"].first.to_i
            else
              @sleep_increment * retries
            end
            puts "---[harvest] Sleeping for #{seconds} seconds"
            sleep(seconds)
            retry
          end
        rescue Harvest::InformHarvest => e
          if would_retry = retry_func.call(e)
            seconds = @sleep_increment * retries
            puts "---[harvest] Sleeping for #{seconds} seconds"
            sleep(seconds)
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
