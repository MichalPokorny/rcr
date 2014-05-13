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

			def start_anew(transformer: nil, allowed_chars: nil, hidden_neurons: nil)
				raise ArgumentError, "No allowed_chars specified" unless allowed_chars
				raise ArgumentError, "You must supply the network topology in hidden_neurons" unless hidden_neurons
				raise ArgumentError, "No input transformer specified" unless transformer

				@transformer = transformer
				raise "No image-to-input transformer specified." unless @transformer

				log "Starting letter classifier anew (#{allowed_chars.size} classes)"
				num_inputs = @transformer.output_size
				@classifier = Classifier::Neural.create(
					num_inputs: num_inputs,
					hidden_neurons: hidden_neurons,
					classes: allowed_chars
				)
			end

			def evaluate(dataset)
				@classifier.evaluate(dataset.transform_inputs { |image| @transformer.transform(image) })
			end

			def train(dataset, generations: 1000, logging: false)
				raise "Internal classifier not prepared." unless @classifier
				raise "Internal transformer not prepared." unless @transformer
				raise ArgumentError unless dataset.is_a? RCR::Data::Dataset

				dataset = dataset.dup
				dataset.transform_inputs! { |image| @transformer.transform(image) }
				dataset.restrict_expected_outputs!(@classifier.classes)

				with_logging_set(logging) do
					log "Training neural classifier of #{@transformer.output_size} inputs for #{generations} generations"
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
				self.new(Marshal.load("#{filename}.transformer"), Marshal.load("#{filename}.classifier"))
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
