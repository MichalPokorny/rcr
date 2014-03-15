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

			def pair_classified_correctly?(x, y)
				classify(x) == y
			end

			class NoSuchClass < StandardError; end

			def evaluate_on_xys(xs, ys)
				raise "Incompatible sizes of xs and ys to evaluate" if xs.size != ys.size
				good, total = 0, 0
				(0...xs.length).each { |i|
					x, y = xs[i], ys[i]
					raise NoSuchClass, "No class #{y} known to classifier (got #{@classes.inspect})" unless @classes.include?(y)

					if classify(x) == y
						good += 1
					else
						#puts "f: got:#{classify(x)} != expect:#{y}"
					end
					total += 1
				}
				#puts
				good.to_f * 100 / total
			end

			def evaluate(dataset)
				raise "Wrong type: #{dataset.class}" unless dataset.is_a? RCR::Data::Dataset
				evaluate_on_xys(*dataset.to_xs_ys_arrays)
			end
		end
	end
end