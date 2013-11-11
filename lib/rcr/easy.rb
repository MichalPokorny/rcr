require 'rcr/config'
require 'rcr/letter-classifier/neural'

module RCR
	def build_letter_classifier(opts = {})
		config =
			if opts.key?(:config)
				opts[:config]
			elsif opts.key?(:config_file)
				RCR::Config.load_from_file(opts[:config_file])
			else
				RCR::Config.instance
			end

		require 'rcr/letter-classifier/neural'
		# TODO: load the classifier we should actually load!
		RCR::LetterClassifier::Neural.load(config.letter_classifier_path)
	end

	def build_language_model(opts = {})
		# TODO: load the language model we should actually load!
	
		# require 'rcr/markov-chain-model'
		# RCR::MarkovChainModel.load_from_corpus(1, '../rcr-data/prepared/corpus')

		nil
	end

	def build_word_segmentator(opts = {})
		require 'rcr/word-segmentator/heuristic-oversegmentation'
		require 'rcr/heuristic-oversegmenter/local-minima'
		# TODO: load the segmentator we should actually load!
		#
		# Old: Stupid instead of LocalMinima
		RCR::WordSegmentator::HeuristicOversegmentation.new(RCR::HeuristicOversegmenter::LocalMinima.new, build_letter_classifier, build_language_model)
	end
end