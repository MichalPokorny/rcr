require 'rcr/config'
require 'rcr/letter_classifier'
require 'rcr/letter_classifier/input_transformer/basic'

module RCR
	module Tasks
		module Train
			def self.run(argv)
				if argv.empty?
					puts "Nothing to do."
					exit
				end

				until argv.empty?
					task = argv.shift

					# trained_dir = RCR::Config.trained_path

					case task.downcase
					when "letter"
						require 'rcr/letter_classifier/neural'
						require 'rcr/feature_extractor/raw_image'
						require 'rcr/feature_extractor/content_aspect_ratio'

						transformers = []

						# TODO: ukladat v datech "jakeho logickeho typu jsou"? Nechci prece
						# na 1D data pripadne poustet konvolucni neuronovou sit...
						transformers << LetterClassifier::InputTransformer::Basic.new(
							FeatureExtractor::RawImage.new(16, 16, guillotine: true, forget_aspect_ratio: true, normalize_contrast: true)
						)

						transformers << LetterClassifier::InputTransformer::Basic.new(
							FeatureExtractor::ContentAspectRatio.new
						)

						lc = LetterClassifier::Neural.new(LetterClassifier::InputTransformer::Combine.new(transformer))

						lc.start_anew(allowed_chars: 'A'..'Z')

						lc.train(LetterClassifier.load_inputs(Config.letter_inputs_path), generations: 1000, logging: true)
						lc.save(Config.letter_classifier_path)
					when "language_model"
						require 'rcr/language_model/markov_chains'
						LanguageModel::MarkovChains.train_from_corpus(3, Config.language_corpus_path).save(Config.language_model_path)

					# when "segment" then
						# TODO: doesn't work!
						# require 'rcr/word_segmentator/default'
						# ws = WordSegmentator::Default.new
						# ws.train(File.join(prepared_dir, "segment.data"))
						# ws.save(File.join(trained_dir, "word-segmentator"))
					# TODO: more
					else
						puts "Don't know how to train '#{task}'."
					end
				end
			end
		end
	end
end
