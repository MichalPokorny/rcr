require 'rcr/data/dataset'

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
				[alternatives.keys.find { |k| alternatives[k] == best }, best]
			end

			def classify(x)
				classify_with_score(x).first
			end

			class NoSuchClass < StandardError; end

			def evaluate(dataset)
				raise "Wrong type: #{dataset.class}" unless dataset.is_a? RCR::Data::Dataset

				good = 0
				dataset.each do |pair|
					x, y = pair
					raise NoSuchClass, "No class #{y} known to classifier (got #{classes.inspect})" unless classes.include?(y)
					good += 1 if classify(x) == y
				end
				good.to_f * 100 / dataset.size
			end
		end
	end
end
