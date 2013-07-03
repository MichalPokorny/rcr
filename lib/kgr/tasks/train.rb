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
						# TODO
						puts "TODO: train letter classifier"
					# TODO: more
					else
						puts "Cannot prepare '#{task}' data"
					end
				end
			end
		end
	end
end
