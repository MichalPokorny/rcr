require 'yaml'

require 'rcr/classifier/neural'

require 'rcr/data/image'
require 'rcr/data/integer_raw_dataset'
require 'fileutils'

require 'rcr/logging'
require 'rcr/marshal'

module RCR
	module LetterClassifier
		class Neural
			include Logging

			MARSHAL_ID = self.name
			include Marshal

#			def self.convert_data_for_torch(source_dir)
#				indexes = {}
#
#				Dir["#{source_dir}/*"].each do |sample_dir|
#					desc = YAML.load_file(File.join(sample_dir, "data.yml"))
#
#					# Create list of letter codes contained in the file.
#					letters = []
#					desc["segments"].each do |segment|
#						letters += (segment["first"]..segment["last"]).to_a.map(&:ord)
#					end
#
#					image = Data::Image.load(File.join(sample_dir, "data.png"))
#
#					data = image.crop_by_columns(letters.count, desc["cell_height"])
#
#					# Make it so that the data is indexed by letter.
#					data.each_index do |index|
#						letter = letters[index].chr
#
#						images = data[index]
#
#						images.each do |img|
#							indexes[letter] ||= 0
#							FileUtils.mkdir_p(File.join(target_dir, letter))
#							path = File.join(target_dir, letter, "#{indexes[letter]}.png")
#							indexes[letter] += 1
#
#							img.save(path)
#						end
#					end
#				end
#			end
#
#			def self.convert_data_for_eblearn(source_dir, target_dir)
#				indexes = {}
#
#				Dir["#{source_dir}/*"].each do |sample_dir|
#					desc = YAML.load_file(File.join(sample_dir, "data.yml"))
#
#					# Create list of letter codes contained in the file.
#					letters = []
#					desc["segments"].each do |segment|
#						letters += (segment["first"]..segment["last"]).to_a.map(&:ord)
#					end
#
#					image = Data::Image.load(File.join(sample_dir, "data.png"))
#
#					data = image.crop_by_columns(letters.count, desc["cell_height"])
#
#					# Make it so that the data is indexed by letter.
#					data.each_index do |index|
#						letter = letters[index].chr
#
#						images = data[index]
#
#						images.each do |img|
#							indexes[letter] ||= 0
#							FileUtils.mkdir_p(File.join(target_dir, letter))
#							path = File.join(target_dir, letter, "#{indexes[letter]}.png")
#							indexes[letter] += 1
#
#							img.save(path)
#						end
#					end
#				end
#			end
#
			def self.load_inputs(source_dir)
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
						images = data[index]

						data_by_letter[letter] ||= []
						data_by_letter[letter] += data[index]

						# Automatic mutations:
						# 0.times { |mutation|
						# 	data_by_letter[letter] += images.map { |img|
						# 		image_to_net_input(img.mutate)
						# 	}
						# }
					end
				end

				data_by_letter
			end

#			def self.prepare_data(source_dir, target_file)
#				data_by_letter = {}
#
#				Dir["#{source_dir}/*"].each do |sample_dir|
#					desc = YAML.load_file(File.join(sample_dir, "data.yml"))
#
#					# Create list of letter codes contained in the file.
#					letters = []
#					desc["segments"].each do |segment|
#						letters += (segment["first"]..segment["last"]).to_a.map(&:ord)
#					end
#
#					image = Data::Image.load(File.join(sample_dir, "data.png"))
#
#					data = image.crop_by_columns(letters.count, desc["cell_height"])
#
#					# Make it so that the data is indexed by letter.
#					data.each_index do |index|
#						letter = letters[index]
#						unless data_by_letter.key?(letter)
#							data_by_letter[letter] = []
#						end
#
#						images = data[index]
#
#						data_by_letter[letter] += images.map { |img|
#							image_to_net_input(img)
#						}
#
#						0.times { |mutation|
#							data_by_letter[letter] += images.map { |img|
#								image_to_net_input(img.mutate)
#							}
#						}
#					end
#				end
#
#				dataset = Data::IntegerRawDataset.new(data_by_letter)
#				dataset.save(target_file)
#			end

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

			#private
#			puts "LOADING DATASET"
#			Data::IntegerRawDataset.load(dataset, RCR::Data::NeuralNetInput)

#			public
#			def self.load_dataset(path, logging: false)
#				Data::IntegerRawDataset.load(path, RCR::Data::NeuralNetInput, logging: logging)
#			end

			def start_anew(dataset, allowed_chars: nil)
				raise unless allowed_chars

				log "Starting letter classifier anew (#{allowed_chars.size} classes)"
				num_inputs = @transformer.output_size
				@classifier = Classifier::Neural.create(num_inputs: num_inputs, hidden_neurons: [14*14, 9*9], classes: allowed_chars)
			end

			def evaluate(dataset)
				raise "Passed dataset is not a IntegerRawDataset" unless dataset.is_a?(Data::IntegerRawDataset)

				@classifier.evaluate(dataset)
			end

			# dataset: hash of class => array of images
			def train(dataset, generations: 100, logging: false)
				pairs = Dataset.new(Hash[dataset.map { |letter, values|
					[letter, values.map { |image| @transformer.transform(image) }]
				}])

				#raise "Passed dataset is not a IntegerRawDataset" unless dataset.is_a?(Data::IntegerRawDataset)

				with_logging_set(logging) do
					raise "Internal classifier not prepared." unless @classifier
					log "Training neural net for letters (#{generations} generations)"

					# TODO: Pridej normalizaci kontrastu. Pridej dalsi parametry?

					log "Training neural classifier of #{@transformer.output_size} inputs"
					@classifier.train(dataset, generations: generations, logging: logging)
				end
			end

			def save_internal(filename)
				log "Saving neural letter classifier to #{filename}"
				@transformer.save("#{filename}.transformer")
				@classifier.save("#{filename}.classifier")
			end

			def initialize(@transformer = nil, @classifier = nil)
				@transformer = transformer
				@classifier = classifier
			end

			def self.load_internal(filename)
				log "Loading neural letter classifier from #{filename}"
				self.new(Marshal.load("#{filename}.transformer"), Classifier::Neural.load(filename))
			end

			def classify(image)
				@classifier.classify(@transformer.transform(image).data).chr
			end

			def classify_with_score(image)
				letter, score = @classifier.classify_with_score(@transformer.transform(image).data)
				[letter.chr, score]
			end

			def classify_with_alternatives(image)
				Hash[
					@classifier.classify_with_alternatives(@transformer.transform(image).data).map { |letter, score|
						[letter.chr, score]
					}
				]
			end
		end
	end
end
