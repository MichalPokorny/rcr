require_relative '../../../test_helper'

module KGR
	module LetterClassifier
		class NeuralTest < Test::Unit::TestCase
			PREPARED = File.join(TEST_DATA_PATH, "tmp", "letter.data")
			CLASSIFIER = File.join(TEST_DATA_PATH, "tmp", "letter-classifier")

			def setup
				@classifier = Neural.new
				Neural.prepare_data(File.join(TEST_DATA_PATH, "letter"), PREPARED)
				@classifier.train(PREPARED)
				@classifier.save(CLASSIFIER)
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
				puts "classifier: #{@classifier.inspect}"

				image = Data::Image.load(File.join(TEST_DATA_PATH, "letter.png"))
				assert @classifier.classify(image)
			end
		end
	end
end
