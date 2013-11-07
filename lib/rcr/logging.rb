require 'rcr'
require 'rcr/config'

module RCR::Logging
	ENABLED_BY_DEFAULT = RCR::Config.logging_enabled

	def self.log_line(*args)
		puts "[log] #{args.join}"
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
			  RCR::Logging.log_line(*args) if logging_enabled?
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
				RCR::Logging.log_line(*args) if logging_enabled?
			end
		end
	end
end
