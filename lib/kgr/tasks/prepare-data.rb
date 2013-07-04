require 'kgr/letter-classifier/neural'

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

					case task.downcase
					when "letter" then
						FileUtils.mkdir_p(prepared_dir)
						LetterClassifier::Neural.prepare_data(File.join(data_dir, "letter"), File.join(prepared_dir, "letter.data"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data."
					end
				end
			end
		end
	end
end
