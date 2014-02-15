require_relative '../../../test_helper'
require 'rcr/data/image'
require 'rcr/heuristic-oversegmenter/oversegmentation'

require_relative '../letter_classifier/neural'

module RCR
	module HeuristicOversegmenter
		class LocalMinimaTest < Test::Unit::TestCase
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

			def test_can_oversegment
				image = Data::Image.load(TEST_INPUT)
				classifier = LetterClassifier::NeuralFunctionalTest.prepare_classifier
				assert classifier

				assert HeuristicOversegmenter::LocalMinima.new.oversegment(image, classifier).is_a?(Oversegmentation)
			end
		end
	end
end
