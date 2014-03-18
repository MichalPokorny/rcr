require_relative '../../../test_helper'
require 'fileutils'

require 'rcr/data/neural_net_input'
require 'rcr/data/dataset'

module RCR
	module Classifier
		class NeuralFunctionalTest < Test::Unit::TestCase
			private
			CLASSES = [1,2,4,5,7,105]
			SAMPLES = 100
			INPUTS = 4
			HIDDEN_NEURONS = [5, 6, 7, 5]

			def create_sample(type, rnd)
				a, b, c, d = *(1..4).map { rnd.rand }
				array = case type
				when CLASSES[0]
					[a/4, b/4, c, d]
				when CLASSES[1]
					[0.25 + a/4, b/4, c, d]
				when CLASSES[2]
					[a, 0.25 + b/2, 0.5 + c/2, d/2]
				when CLASSES[3]
					[a, 0.25 + b/2, c/2, 0.5 + d/2]
				when CLASSES[4]
					[a/2 + 0.3, b/2 + 0.3, c/5, d/5]
				when CLASSES[5]
					[a, 0.7 + b/3, c, d]
				end
				Data::NeuralNetInput.new(array)
			end

			def make_dataset
				rnd = Random.new(12345)
				Data::Dataset.new(Hash[
					CLASSES.map { |c|
						[c, SAMPLES.times.map { create_sample(c, rnd) }]
					}
				])
			end

			public
			def test_create
				classifier = Neural.create(num_inputs: INPUTS, hidden_neurons: HIDDEN_NEURONS, classes: CLASSES)
				assert classifier && classifier.is_a?(RCR::Classifier::Neural)

				dataset = make_dataset

				e = classifier.evaluate(dataset)
				assert e.is_a?(Float) && e >= 0.0 && e <= 100.0 # Returned value in percents

				classifier.train(dataset, logging: false, generations: 100)
				e2 = classifier.evaluate(dataset)
				assert e2.is_a?(Float) && e2 >= 0.0 && e2 <= 100.0 # Returned value in percents
				assert e2 > e, "evaluation didn't rise after training"

				rnd = Random.new(31415)
				10.times {
					c = CLASSES.shuffle.first
					sample = create_sample(c, rnd)

					assert CLASSES.include?(classifier.classify(sample))

					cl, score = classifier.classify_with_score(sample)
					assert score && cl && score.is_a?(Float)

					alts = classifier.classify_with_alternatives(sample)
					assert alts.is_a?(Hash) && alts.keys.all? { |k| CLASSES.include?(k) }
				}
			end

			def test_loading_doesnt_change_evaluation
				dataset = make_dataset

				classifier = Neural.create(num_inputs: INPUTS, hidden_neurons: HIDDEN_NEURONS, classes: CLASSES)
				classifier.train(dataset, logging: false, generations: 100)

				path = File.join(TEST_DATA_PATH, "neural_classifier")
				classifier.save(path)

				classifier2 = Neural.load(path)
				assert classifier2 && classifier2.is_a?(RCR::Classifier::Neural)

				rnd = Random.new(123)
				10.times {
					c = CLASSES.shuffle.first
					sample = create_sample(c, rnd)
					assert_equal classifier.classify(sample), classifier2.classify(sample)
				}
				assert_equal classifier.evaluate(dataset), classifier2.evaluate(dataset)
			end
		end
	end
end
