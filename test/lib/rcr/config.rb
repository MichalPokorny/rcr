require 'rcr/config'

module RCR
	class ConfigTest
		def self.prepare_config
			path = File.join(TEST_DATA_PATH, "tmp", "letter-classifier")
			RCR::LetterClassifier::NeuralFunctionalTest.prepare_classifier.save(path)

			RCR::Config.new(
				data_path: TEST_DATA_PATH,
				letter_classifier_path: path
			)
		end
	end
end
