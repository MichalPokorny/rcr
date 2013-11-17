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

					# cell_index = 1

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

					# cell_index = 1

					# Make it so that the data is indexed by letter.
					data.each_index do |index|
						letter = letters[index]
						unless data_by_letter.key?(letter)
							data_by_letter[letter] = []
						end

						images = data[index]

						# ci = cell_index
						data_by_letter[letter] += images.map { |img|
							cell_data = image_to_net_input(img)
							# img.save("pristine_#{ci}.png")
							# ci += 1

							cell_data
						}

						0.times { |mutation|
							# ci = cell_index
							data_by_letter[letter] += images.map { |img|
								mutated = img.mutate
								cell_data = image_to_net_input(mutated)
								# mutated.save("mutated_#{ci}_#{mutation}.png")
								# ci += 1

								cell_data
							}
						}

						# cell_index = ci
					end
				end

				dataset = Data::IntegerRawDataset.new(data_by_letter)
				dataset.save(target_file)
			end

			def self.data_inputs_size(data)
				raise "Data entirely empty" if data.keys.empty?
				inputs = data[data.keys.first]
				# puts "inputs first: #{inputs.first.inspect}"
				size = inputs.first.size
				size
			end

			def train(dataset, allowed_chars: ('A'..'Z'), generations: 100)
				log "Training neural net for letters (#{allowed_chars.size} classes, #{generations} generations)"

				data = dataset
				
				# TODO: Pridej normalizaci kontrastu. Pridej dalsi parametry?
				if dataset.is_a? String
					data = Data::IntegerRawDataset.load(dataset, RCR::Data::NeuralNetInput)
				end

				# Restrict keys to allowed characters
				for k in data.keys
					unless allowed_chars.include?(k.chr)
						data.delete k
					end
				end

				num_inputs = self.class.data_inputs_size(data)
				log "num_inputs: #{num_inputs}"
				@classifier = Classifier::Neural.create(num_inputs: num_inputs, hidden_neurons: [ 14*14, 9*9 ], classes: allowed_chars.to_a.map(&:ord))
				@classifier.train(data, generations: generations)
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
