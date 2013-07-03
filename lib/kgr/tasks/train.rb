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
						LetterClassifier::Neural.train
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
