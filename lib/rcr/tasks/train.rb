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
						transformer = LetterClassifier::InputTransformer::Basic.create(guillotine: true, forget_aspect_ratio: true, normalize_contrast: true)
						lc = LetterClassifier::Neural.new(transformer)
						lc.start_anew(allowed_chars: 'A'..'Z')

						lc.train(LetterClassifier.load_inputs(Config.letter_inputs_path), generations: 1000, logging: true)
						lc.save(Config.letter_classifier_path)
					# when "segment" then
						# TODO: doesn't work!
						# require 'rcr/word-segmentator/default'
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
