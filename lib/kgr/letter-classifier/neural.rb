require 'yaml'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data
				dir = "/home/prvak/rocnikac/kgr-data"

				puts "TODO: prepare letter classifier data"

				Dir["#{dir}/letter/*"].each do |sample_dir|
					puts "TODO: prepare #{sample_dir} data"
					
					desc = YAML.load_file(File.join(sample_dir, "data.yml"))

					p desc
				end
			end
		end
	end
end
