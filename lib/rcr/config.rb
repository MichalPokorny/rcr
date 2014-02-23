require 'pathname'
require 'yaml'

module RCR
	class Config
		class InvalidConfiguration < StandardError; end

		def self.instance
			@instance ||= self.load_from_file(Pathname.new("~/.rcr-config.yml").expand_path)
		end

		def self.load_from_file(path)
			settings =
				if File.exist?(path)
					YAML.load_file(path)
				else
					puts "Loading default configuration."
					{}
				end

			self.new(settings)
		end

		def self.method_missing(*args)
			self.instance.send(*args)
		end

		def initialize(settings)
			# Normalize: use symbols.
			@settings = Hash[settings.map { |k, v| [k.to_sym, v] }]
		end

		private
		def expand(thing)
			Pathname.new(thing).expand_path
		end

		public
		def data_path
			raise InvalidConfiguration, "No data directory defined." unless @settings.key?(:data_path)
			expand @settings[:data_path]
		end

		private
		def expand_or(key)
			@settings[key] ? expand(@settings[key]) : yield
		end

		public
		def trained_path
			expand_or(:trained_path) { File.join(data_path, "trained") }
		end

		def input_path
			expand_or(:input_path) { File.join(data_path, "input") }
		end

		def letter_inputs_path
			expand_or(:letter_inputs_path) { File.join(input_path, "letter") }
		end

		def segmentation_inputs_path
			expand_or(:segmentation_inputs_path) { File.join(input_path, "segment") }
		end

		def word_segmenter_path
			expand_or(:word_segmented_path) { File.join(trained_path, "word-segmenter") }
		end

		# TODO: allow using more classifiers for different purposes
		def letter_classifier_path
			expand_or(:letter_classifier_path) { File.join(trained_path, "letter-classifier") }
		end

		def logging_enabled
			@settings[:debug]
		end

		def language_model_path
			expand_or(:language_model_path) { File.join(trained_path, "language-model") }
		end

		def language_corpus_path
			expand_or(:language_corpus_path) { File.join(input_path, "corpus.txt") }
		end
	end
end
