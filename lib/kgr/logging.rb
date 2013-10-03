module Logging
	def self.included(klass)
		klass.instance_eval do
			define_method :log do |*args|
				puts("LOG:", *args) if defined?(@enable_logging) && @enable_logging
			end

			attr_accessor :enable_logging
		end

		class << klass
			define_method :log do |*args|
				puts("LOG:", *args) if defined?(@enable_logging) && @enable_logging
			end
		end
	end
end
