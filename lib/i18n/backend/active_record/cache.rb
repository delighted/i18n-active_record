I18n::RESERVED_KEYS << :cache

module I18n
  module Backend
    class ActiveRecord
      class Cache
        attr_reader :store, :logger
        private :store, :logger

        def initialize(logger: nil)
          @logger = logger
          @store = Hash.new { |h, k| h[k] = {} }
        end

        def cached(locale, key, options)
          seperator = options[:seperator] || I18n::Backend::ActiveRecord::FLATTEN_SEPARATOR
          scope = key.split(seperator).first.to_s

          if store.key?(locale) && store[locale].key?(scope)
            logger.debug "Cache hit: #{locale.inspect}/#{key.inspect} (cache scope=#{scope.inspect})" if logger
          else
            logger.debug "Cache miss: #{locale.inspect}/#{key.inspect} (cache scope=#{scope.inspect})" if logger
            store[locale][scope] = yield(locale, scope)
          end

          if scope == ""
            store[locale][scope]
          else
            store[locale][scope].select do |translation|
              translation.key == key ||
              translation.key.start_with?("#{key}#{seperator}")
            end
          end
        end
      end
    end
  end
end
