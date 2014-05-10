require 'rcr/config'
require 'rcr/letter_classifier'
require 'rcr/letter_classifier/input_transformer/basic'

module RCR
	module Tasks
		module Train
			def self.run(argv)
				if argv.empty?
					puts "Nothing to do. Pass 'letter' or 'language_model' to train RCR components."
					exit
				end

				while task = argv.shift
					case task.downcase
					when "letter"
						require 'rcr/letter_classifier/neural'
						require 'rcr/letter_classifier/input_transformer/combine'
						require 'rcr/feature_extractor/raw_image'
						require 'rcr/feature_extractor/content_aspect_ratio'

						transformers = []

						transformers << LetterClassifier::InputTransformer::Basic.new(
							FeatureExtractor::RawImage.new(16, 16, guillotine: true, forget_aspect_ratio: true, normalize_contrast: true)
						)

						transformers << LetterClassifier::InputTransformer::Basic.new(
							FeatureExtractor::ContentAspectRatio.new
						)

						transformer = LetterClassifier::InputTransformer::Combine.new(transformers)
						lc = LetterClassifier::Neural.new

						lc.start_anew(transformer: transformer, allowed_chars: 'A'..'Z', hidden_neurons: [14*14, 9*9])

						lc.train(LetterClassifier.load_inputs(Config.letter_inputs_path), generations: 1000, logging: true)
						lc.save(Config.letter_classifier_path)
					when "language-model"
						require 'rcr/language_model/markov_chains'
						corpus = File.read(Config.language_corpus_path).each_char.select { |c| c =~ /[a-zA-Z]/ }.map(&:upcase)

						lm = LanguageModel::MarkovChains.new(3)
						lm.train(corpus)
						lm.save(Config.language_model_path)
					else
						puts "Don't know how to train '#{task}'."
					end
				end
			end
		end
	end
end
