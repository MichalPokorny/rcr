require 'yaml'
require 'kgr/data/image'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data
				dir = "/home/prvak/rocnikac/kgr-data"

				puts "TODO: prepare letter classifier data"

				Dir["#{dir}/letter/*"].each do |sample_dir|
					puts "TODO: prepare #{sample_dir} data"
					
					desc = YAML.load_file(File.join(sample_dir, "data.yml"))

					# Create list of letter codes contained in the file.
					letters = []
					desc["segments"].each do |segment|
						letters += (segment["first"]..segment["last"]).to_a.map(&:ord)
					end

					image = Data::Image.load(File.join(sample_dir, "data.png"))

					data = image.crop_by_columns(letters.count, desc["cell_height"])

					data.each_index do |index|
						puts "#{data[index].count} samples of letter #{letters[index]}"
					end
				end
			end
		end
	end
end
