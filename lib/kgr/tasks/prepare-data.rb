require 'kgr/letter-classifier/neural'
require 'kgr/word-segmentator/default'

module KGR
	module Tasks
		module PrepareData
			def self.run(argv)
				if argv.empty?
					puts "Nothing to do."
					exit
				end

				until argv.empty?
					task = argv.shift

					data_dir = "/home/prvak/rocnikac/kgr-data/input"
					prepared_dir = "/home/prvak/rocnikac/kgr-data/prepared"

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
