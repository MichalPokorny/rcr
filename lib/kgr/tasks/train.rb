require 'kgr/letter-classifier/neural'

module KGR
	module Tasks
		module Train
			def self.run(argv)
				if argv.empty?
					puts "Nothing to do."
					exit
				end

				until argv.empty?
					task = argv.shift

					prepared_dir = "/home/prvak/rocnikac/kgr-data/prepared"
					trained_dir = "/home/prvak/rocnikac/kgr-data/trained"
					
					case task.downcase
					when "letter" then
						lc = LetterClassifier::Neural.new
						lc.train(File.join(prepared_dir, "letter.data"))
						lc.save(File.join(trained_dir, "letter-classifier"))
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
