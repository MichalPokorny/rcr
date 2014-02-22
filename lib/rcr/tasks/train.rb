require 'rcr/config'

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
					when "letter" then
						require 'rcr/letter_classifier/neural'
						transformer = LetterClassifier::InputTransformer::Basic.new(guillotine: true, forget_aspect_ratio: true)
						lc = LetterClassifier::Neural.new(transformer)
						dataset = LetterClassifier::Neural.load_inputs(Config.letter_inputs_path)
						chars = ('A'..'Z')
						dataset = dataset.restrict_keys(chars.map(&:ord))
						lc.start_anew(allowed_chars: chars)

						# chars = dataset.keys.map(&:chr)
						# puts "chars: #{chars.inspect}"
						# lc.start_anew(dataset, allowed_chars: chars)
						lc.train(dataset, logging: true)
						lc.save(Config.letter_classifier_path)
					# when "segment" then
						# TODO: doesn't work!
						# require 'rcr/word-segmentator/default'
						# ws = WordSegmentator::Default.new
						# ws.train(File.join(prepared_dir, "segment.data"))
						# ws.save(File.join(trained_dir, "word-segmentator"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
