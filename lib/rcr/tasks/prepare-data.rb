require 'rcr/config'
require 'rcr/letter-classifier/neural'
require 'rcr/word-segmentator/default'

module RCR
	module Tasks
		module PrepareData
			def self.run(argv)
				if argv.empty?
					puts "Nothing to do."
					exit
				end

				until argv.empty?
					task = argv.shift

					data_dir = Config.input_path
					prepared_dir = Config.prepared_path

					FileUtils.mkdir_p(prepared_dir)

					case task.downcase
					when "letter" then
						LetterClassifier::Neural.prepare_data(File.join(data_dir, "letter"), File.join(prepared_dir, "letter.data"))
					when "segment" then
						WordSegmentator::Default.prepare_data(File.join(data_dir, "segment"), File.join(prepared_dir, "segment.data"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data."
					end
				end
			end
		end
	end
end
