require 'rcr/logging'
require 'rcr/marshal'
require 'rcr/classifier/neural'
require 'rcr/data/image'
require 'fileutils'
require 'rcr/data/dataset'
require 'rcr/letter_classifier/base'

module RCR
	module LetterClassifier
		class Neural < Base
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
			def start_anew(allowed_chars: nil)
				raise unless allowed_chars

				log "Starting letter classifier anew (#{allowed_chars.size} classes)"
				raise "You forgot to specify an image-to-input transformer." unless @transformer
				num_inputs = @transformer.output_size
				@classifier = Classifier::Neural.create(num_inputs: num_inputs, hidden_neurons: [14*14, 9*9], classes: allowed_chars)
			end

			def evaluate(dataset)
				@classifier.evaluate(dataset)
			end

			def inputs_to_dataset(inputs)
				Data::Dataset.new(inputs.map { |letter, values|
					[values.map { |image| @transformer.transform(image) }, letter]
				})
			end

			# dataset: hash of class => array of images
			def train(inputs, generations: 1000, logging: false)
				with_logging_set(logging) do
					dataset = inputs_to_dataset(inputs)

					log "Dataset before key restrictions has #{dataset.size} samples."
					dataset = dataset.restrict_keys(@classifier.classes)
					log "Dataset after key restriction has #{dataset.size} samples."

					raise "Internal classifier not prepared." unless @classifier
					log "Training neural net for letters (#{generations} generations)"

					# TODO: Pridej normalizaci kontrastu. Pridej dalsi parametry?

					log "Training neural classifier of #{@transformer.output_size} inputs"
					#@classifier.cascade_train(dataset, max_neurons: 1000, logging: logging)
					@classifier.train(dataset, generations: generations, logging: logging)
				end
			end

			def save_internal(filename)
				log "Saving neural letter classifier to #{filename}"
				@transformer.save("#{filename}.transformer")
				@classifier.save("#{filename}.classifier")
			end

			def initialize(transformer = nil, classifier = nil)
				@transformer = transformer
				@classifier = classifier
			end

			def self.load_internal(filename)
				log "Loading neural letter classifier from #{filename}"
				self.new(Marshal.load("#{filename}.transformer"), Classifier::Neural.load("#{filename}.classifier"))
			end

			def classify(image)
				@classifier.classify(@transformer.transform(image))
			end

			def classify_with_score(image)
				@classifier.classify_with_score(@transformer.transform(image))
			end

			def classify_with_alternatives(image)
				@classifier.classify_with_alternatives(@transformer.transform(image))
			end
		end
	end
end
