require 'yaml'

require 'rcr/classifier/neural'

require 'rcr/data/image'
require 'rcr/data/integer_raw_dataset'
require 'fileutils'

require 'rcr/logging'

module RCR
	module LetterClassifier
		class Neural
			include Logging

			def self.convert_data_for_eblearn(source_dir, target_dir)
				indexes = {}

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
						letter = letters[index].chr

						images = data[index]

						images.each do |img|
							indexes[letter] ||= 0
							FileUtils.mkdir_p(File.join(target_dir, letter))
							path = File.join(target_dir, letter, "#{indexes[letter]}.png")
							indexes[letter] += 1

							img.save(path)
						end
					end
				end
			end

			def self.image_to_net_input(image)
				NeuralNet.image_to_input(image, guillotine: true, rescale: false)
			end

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

						images = data[index]

						data_by_letter[letter] += images.map { |img|
							image_to_net_input(img)
						}

						0.times { |mutation|
							data_by_letter[letter] += images.map { |img|
								image_to_net_input(img.mutate)
							}
						}
					end
				end

				dataset = Data::IntegerRawDataset.new(data_by_letter)
				dataset.save(target_file)
			end

			# TODO: move to 'integer_raw_dataset'?
			def self.data_inputs_size(data)
				raise "Dataset has no keys, can't detect input size" if data.keys.empty?
				inputs = data[data.keys.first]
				# puts "inputs first: #{inputs.first.inspect}"
				size = inputs.first.size
				size
			end

			def untrain(inputs, generations: 100, logging: false)
				log "Untraining neural classifier."

				raise "unimplemented"
			end

			private
#			puts "LOADING DATASET"
#			Data::IntegerRawDataset.load(dataset, RCR::Data::NeuralNetInput)

			public
			def self.load_dataset(path, logging: false)
				Data::IntegerRawDataset.load(path, RCR::Data::NeuralNetInput, logging: logging)
			end

			def start_anew(dataset, allowed_chars: nil)
				raise unless allowed_chars
				raise "Passed dataset is not a IntegerRawDataset" unless dataset.is_a?(Data::IntegerRawDataset)

				log "Starting new neural net for letter classifier (#{allowed_chars.size} classes)"
				num_inputs = self.class.data_inputs_size(dataset)
				@classifier = Classifier::Neural.create(num_inputs: num_inputs, hidden_neurons: [ 14*14, 9*9 ], classes: allowed_chars.to_a.map(&:ord))
			end

			def evaluate(dataset)
				raise "Passed dataset is not a IntegerRawDataset" unless dataset.is_a?(Data::IntegerRawDataset)

				@classifier.evaluate(dataset)
			end

			def train(dataset, generations: 100, logging: false)
				raise "Passed dataset is not a IntegerRawDataset" unless dataset.is_a?(Data::IntegerRawDataset)

				with_logging_set(logging) do
					raise "Internal classifier not prepared." unless @classifier
					log "Training neural net for letters (#{generations} generations)"

					# TODO: Pridej normalizaci kontrastu. Pridej dalsi parametry?

					# Restrict keys to allowed characters
					#for k in dataset.keys
					#	unless allowed_chars.include?(k.chr)
					#		dataset.delete k
					#	end
					#end

					num_inputs = self.class.data_inputs_size(dataset)
					log "Training neural classifier of #{num_inputs} inputs"
					@classifier.train(dataset, generations: generations, logging: logging)
				end
			end

			def save(filename)
				log "Saving neural letter classifier to #{filename}"
				@classifier.save(filename)
			end

			def initialize(classifier = nil)
				@classifier = classifier
			end

			def self.load(filename)
				log "Loading neural letter classifier from #{filename}"
				self.new(Classifier::Neural.load(filename))
			end

			def classify(image)
				@classifier.classify(self.class.image_to_net_input(image).data)
			end

			def classify_with_score(image)
				@classifier.classify_with_score(self.class.image_to_net_input(image).data)
			end

			def classify_with_alternatives(image)
				@classifier.classify_with_alternatives(self.class.image_to_net_input(image).data)
			end
		end
	end
end
