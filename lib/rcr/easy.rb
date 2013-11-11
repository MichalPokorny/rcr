require 'rcr/letter-classifier/neural'

module RCR
	def build_letter_classifier
		require 'rcr/letter-classifier/neural'
		# TODO: load the classifier we should actually load!
		RCR::LetterClassifier::Neural.load(RCR::Config.letter_classifier_path)
	end

	def build_language_model
		# TODO: load the language model we should actually load!
	
		# require 'rcr/markov-chain-model'
		# RCR::MarkovChainModel.load_from_corpus(1, '../rcr-data/prepared/corpus')

		nil
	end

	def build_word_segmentator
		require 'rcr/word-segmentator/heuristic-oversegmentation'
		require 'rcr/heuristic-oversegmenter/local-minima'
		# TODO: load the segmentator we should actually load!
		#
		# Old: Stupid instead of LocalMinima
		RCR::WordSegmentator::HeuristicOversegmentation.new(RCR::HeuristicOversegmenter::LocalMinima.new, build_letter_classifier, build_language_model)
	end
end
