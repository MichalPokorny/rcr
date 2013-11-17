require_relative '../../../test_helper'
require 'fileutils'

module RCR
	module LetterClassifier
		class NeuralFunctionalTest < Test::Unit::TestCase
			INPUTS = File.join(TEST_DATA_PATH, "letter", "train")
			PREPARED = File.join(TEST_DATA_PATH, "tmp", "letter.data")
			CLASSIFIER = File.join(TEST_DATA_PATH, "tmp", "letter-classifier")
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

			RANGE = ('0'..'9')

			def self.prepare_classifier
				classifier = Neural.new
				Neural.prepare_data(INPUTS, PREPARED)
				unless File.exist? PREPARED
					raise "Didn't properly prepare the data!"
				end
				classifier.start_anew(PREPARED, allowed_chars: RANGE)
				classifier.train PREPARED, allowed_chars: RANGE, generations: 5
				classifier
			end

			def prepare_classifier
				@classifier = self.class.prepare_classifier
				@classifier.save CLASSIFIER
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
				classifier = Neural.load(CLASSIFIER)
				assert classifier
			end

			def test_can_classify_loaded_image
				image = Data::Image.load(TEST_INPUT)
				result = @classifier.classify(image)
				pp result
				assert result
			end

			def test_can_classify_with_alternatives
				image = Data::Image.load(TEST_INPUT)
				result = @classifier.classify_with_alternatives(image)
				assert result && result.is_a?(Hash) && result.values.all? { |k| k.is_a?(Float) }
			end
		end
	end
end
