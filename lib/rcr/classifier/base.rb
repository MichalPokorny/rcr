module RCR
	module Classifier
		class Base
			include Logging

			attr_reader :classes

			def initialize(classes = nil)
				@classes = classes.to_a
			end

			def classify_with_alternatives(x)
				raise "Base classifier doesn't implement classify_with_alternatives"
			end

			def classify_with_score(x)
				alternatives = classify_with_alternatives(x)
				best = alternatives.values.max
				[alternatives.keys.select { |k| alternatives[k] == best }, best]
			end

			def classify(x)
				classify_with_score(x).first
			end
		end
	end
end
