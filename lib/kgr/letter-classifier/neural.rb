require 'yaml'
require 'kgr/data/image'
require 'kgr/data/integer_raw_dataset'
require 'kgr/neural-net'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data
				dir = "/home/prvak/rocnikac/kgr-data"

				puts "TODO: prepare letter classifier data"

				data_by_letter = {}

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

					# Make it so that the data is indexed by letter.
					data.each_index do |index|
						letter = letters[index]
						unless data_by_letter.key?(letter)
							data_by_letter[letter] = []
						end

						data_by_letter[letter] += data[index]
					end
				end

				dataset = Data::IntegerRawDataset.new(data_by_letter)
				dataset.save("/home/prvak/rocnikac/kgr-prepared/letter.bin")
			end

			def train
				puts "Training neural net for letters"

				data = {}
				
				dataset = Data::IntegerRawDataset.load("/home/prvak/rocnikac/kgr-prepared/letter.bin")
				dataset.keys.each { |key|
					data[key] = dataset[key].map { |item|
						NeuralNet.image_to_data(item)
					}
				}
			end
		end
	end
end
