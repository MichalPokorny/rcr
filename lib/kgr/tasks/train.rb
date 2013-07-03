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

					case task.downcase
					when "letter" then
						lc = LetterClassifier::Neural.new
						lc.train
						lc.save("letter-classifier.net")
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
