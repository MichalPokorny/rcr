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

					prepared_dir = RCR::Config.prepared_path
					trained_dir = RCR::Config.trained_path

					case task.downcase
					when "letter" then
						require 'rcr/letter-classifier/neural'
						lc = LetterClassifier::Neural.new
						dataset = LetterClassifier::Neural.load_dataset(Config.prepared_letter_data_path)
						chars = ('A'..'Z')
						dataset = dataset.restrict_keys(chars.map(&:ord))
						lc.start_anew(dataset, allowed_chars: chars)
						lc.train(dataset, logging: true)
						puts "eval before save: #{lc.evaluate(dataset)}"
						lc.save(Config.letter_classifier_path)
						puts "eval after save: #{lc.evaluate(dataset)}"
					when "segment" then
						# TODO: doesn't work!
						require 'rcr/word-segmentator/default'
						ws = WordSegmentator::Default.new
						ws.train(File.join(prepared_dir, "segment.data"))
						ws.save(File.join(trained_dir, "word-segmentator"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
