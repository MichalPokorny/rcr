require_relative '../../test_helper'
require_relative 'config'

require 'rcr/easy'

module RCR
	class EasyTest < Test::Unit::TestCase
		TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

		def test_letter_classifier
			classifier = RCR.build_letter_classifier(config: RCR::ConfigTest.prepare_config)
			assert classifier.is_a?(RCR::LetterClassifier::Neural)

			result = classifier.classify(RCR::Data::Image.load(TEST_INPUT))
			assert result && result.is_a?(String)
		end
	end
end
