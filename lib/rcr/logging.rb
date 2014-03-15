require 'rcr'
require 'rcr/config'

module RCR::Logging
	ENABLED_BY_DEFAULT = RCR::Config.logging_enabled

	def self.log_line(source, args)
		puts "[#{source}] #{args.map(&:to_s).join}"
	end

	def self.included(klass)
		klass.instance_eval do
			define_method :logging_enabled? do
				if defined?(@enable_logging)
					@enable_logging
				else
					ENABLED_BY_DEFAULT
				end
			end

			define_method :log do |*args|
			  RCR::Logging.log_line(self.class, args) if logging_enabled?
			end

			define_method :warn do |*args|
				puts "[#{self.class}] WARN: #{args.map(&:to_s).join}"
			end

			define_method :with_logging do |&block|
				with_logging_set(true, &block)
			end

			define_method :without_logging do |&block|
				with_logging_set(false, &block)
			end

			define_method :with_logging_set do |value, &block|
				old_value = defined?(@enable_logging) ? @enable_logging : nil
				@enable_logging = value
				block.call
				@enable_logging = old_value
			end

			attr_accessor :enable_logging
		end

		class << klass
			define_method :logging_enabled? do
				if defined?(@enable_logging)
					@enable_logging
				else
					ENABLED_BY_DEFAULT
				end
			end

			define_method :log do |*args|
				RCR::Logging.log_line(self, args) if logging_enabled?
			end

			define_method :warn do |*args|
				puts "[#{self.class}] WARN: #{args.map(&:to_s).join}"
			end

			define_method :with_logging do |&block|
				with_logging_set(true, &block)
			end

			define_method :without_logging do |&block|
				with_logging_set(false, &block)
			end

			define_method :with_logging_set do |value, &block|
				old_value = defined?(@enable_logging) ? @enable_logging : nil
				@enable_logging = value
				result = block.call
				@enable_logging = old_value
				result
			end
		end
	end
end
