require_relative '../../../test_helper'
require 'fileutils'

module RCR
	module LetterClassifier
		INPUTS = File.join(TEST_DATA_PATH, "letter", "train")
		PREPARED = File.join(TEST_DATA_PATH, "tmp", "letter.data")
		CLASSIFIER = File.join(TEST_DATA_PATH, "tmp", "letter-classifier")
		TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

		class NeuralTest < Test::Unit::TestCase
			PREPARED = File.join(TEST_DATA_PATH, "tmp", "letter.data")

			def setup
				Neural.prepare_data(INPUTS, PREPARED)
			end

			def teardown
				FileUtils.rm_f(PREPARED)
				FileUtils.rm_f(CLASSIFIER)
			end

			def test_double_loading_gives_same_inputs
				dataset1 = Neural.load_dataset(PREPARED)
				dataset2 = Neural.load_dataset(PREPARED)

				assert dataset1 == dataset2
			end
		end

		class NeuralFunctionalTest < Test::Unit::TestCase
			RANGE = ('0'..'9')

			def self.prepare_classifier
				classifier = Neural.new
				Neural.prepare_data(INPUTS, PREPARED)
				unless File.exist? PREPARED
					raise "Didn't properly prepare the data!"
				end
				dataset = Neural.load_dataset(PREPARED)
				classifier.start_anew(dataset, allowed_chars: RANGE)
				classifier.train(dataset, generations: 5)
				classifier
			end

			def prepare_classifier
				@classifier = self.class.prepare_classifier
				@classifier.save_internal CLASSIFIER
			end

			def setup
				prepare_classifier
			end

			def destroy_classifier
				FileUtils.rm_f(PREPARED)
				FileUtils.rm_f(CLASSIFIER)
			end

			def teardown
				destroy_classifier
			end

			def test_can_load_classifier
				classifier = Neural.load_internal(CLASSIFIER)
				assert classifier
			end

			def test_can_classify_loaded_image
				image = Data::Image.load(TEST_INPUT)
				result = @classifier.classify(image)
				assert result && result.is_a?(String)
			end

			def test_can_classify_with_alternatives
				image = Data::Image.load(TEST_INPUT)
				result = @classifier.classify_with_alternatives(image)
				assert result && result.is_a?(Hash) && result.values.all? { |k| k.is_a?(Float) } && result.keys.all? { |k| k.is_a?(String) }
			end
		end
	end
end
