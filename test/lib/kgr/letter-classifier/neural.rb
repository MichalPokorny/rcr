require_relative '../../../test_helper'
require 'fileutils'

module KGR
	module LetterClassifier
		class NeuralTest < Test::Unit::TestCase
			INPUTS = File.join(TEST_DATA_PATH, "letter", "train")
			PREPARED = File.join(TEST_DATA_PATH, "tmp", "letter.data")
			CLASSIFIER = File.join(TEST_DATA_PATH, "tmp", "letter-classifier")
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

			def setup
				FileUtils.mkdir_p(File.join(TEST_DATA_PATH, "tmp"))
				@classifier = Neural.new
				Neural.prepare_data(INPUTS, PREPARED)
				assert File.exist? PREPARED
				@classifier.train PREPARED, allowed_chars: ('0'..'9'), generations: 5
				@classifier.save CLASSIFIER
			end

			def teardown
				FileUtils.rm_f(PREPARED)
				FileUtils.rm_f(CLASSIFIER)
			end

			def test_can_load_classifier
				classifier = Neural.load(CLASSIFIER)
				assert classifier
			end

			def test_can_classify_loaded_image
				image = Data::Image.load(TEST_INPUT)
				assert @classifier.classify(image)
			end
		end
	end
end
