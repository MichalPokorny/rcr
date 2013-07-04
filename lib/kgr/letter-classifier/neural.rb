require 'yaml'

require 'kgr/classifier/neural'

require 'kgr/data/image'
require 'kgr/data/integer_raw_dataset'
require 'fileutils'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data(source_dir, target_file)
				data_by_letter = {}

				Dir["#{source_dir}/*"].each do |sample_dir|
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
				dataset.save(target_file)
			end

			def self.data_inputs_size(data)
				p data.keys.first
				inputs = data[data.keys.first]
				puts "inputs first: #{inputs.first.inspect}"
				size = inputs.first.size
				size
			end

			def train(dataset_file)
				puts "Training neural net for letters"

				data = {}
				
				# TODO: Pridej normalizaci kontrastu. Pridej dalsi parametry?
				dataset = Data::IntegerRawDataset.load(dataset_file)
				dataset.keys.each { |key|
					data[key] = dataset[key].map { |item|
						NeuralNet.image_to_data(item)
					}
				}

				# Restrict keys to A..Z
				keys = data.keys
				#allowed = Set.new(('0'..'9').to_a + ('A'..'Z').to_a)
				allowed = ('A'..'Z').to_a
				for k in keys
					unless allowed.include?(k.chr)
						data.delete k
					end
				end

				num_inputs = self.class.data_inputs_size(data)
				puts "num_inputs: #{num_inputs}"
				@classifier = Classifier::Neural.create(num_inputs: num_inputs, hidden_neurons: [ 128, 80, 60 ], classes: allowed.to_a.map(&:ord))
				@classifier.train(data)
			end

			def save(filename)
				@classifier.save(filename)
			end

			def initialize(classifier = nil)
				@classifier = classifier
			end

			def self.load(filename)
				self.new(Classifier::Neural.load(filename))		
			end

			def classify(image)
				@classifier.classify(NeuralNet.image_to_data(image))
			end
		end
	end
end
