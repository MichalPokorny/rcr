require 'rcr/letter-classifier/neural'
require 'rcr/word-segmentator/default'

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

					prepared_dir = Config.prepared_path
					trained_dir = Config.trained_path
					
					case task.downcase
					when "letter" then
						lc = LetterClassifier::Neural.new
						lc.train(File.join(prepared_dir, "letter.data"))
						lc.save(File.join(trained_dir, "letter-classifier"))
					when "segment" then
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
