require 'rcr/config'
require 'rcr/letter_classifier/neural'

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

					prepared_dir = Config.prepared_path

					FileUtils.mkdir_p(prepared_dir)

					case task.downcase
					when "letter" then
						LetterClassifier::Neural.prepare_data(Config.letter_inputs_path, Config.prepared_letter_data_path)
					when "segment" then
						raise "Not implemented"
						# require 'rcr/word-segmentator/default'
						# WordSegmentator::Default.prepare_data(File.join(data_dir, "segment"), File.join(prepared_dir, "segment.data"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data."
					end
				end
			end
		end
	end
end
