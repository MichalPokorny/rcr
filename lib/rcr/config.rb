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
				end

			settings = File.exist?(path) ? YAML.load_file(path) : {}
			self.new(settings)
		end

		def self.method_missing(*args)
			self.instance.send(*args)
		end

		def initialize(settings)
			@settings = settings
		end

		private
		def expand(thing)
			Pathname.new(thing).expand_path
		end

		public
		def data_path
			raise InvalidConfiguration, "No data directory defined." unless @settings.key?("data_path")
			expand @settings["data_path"]
		end

		def trained_path
			@settings["trained_path"] ? expand(@settings["trained_path"]) : File.join(data_path, "trained")
		end

		def input_path
			@settings["input_path"] ? expand(@settings["input_path"]) : File.join(data_path, "input")
		end

		def prepared_path
			@settings["prepared_path"] ? expand(@settings["prepared_path"]) : File.join(data_path, "prepared")
		end

		def letter_inputs_path
			File.join(input_path, "letter")
		end

		def segmentation_inputs_path
			File.join(input_path, "segment")
		end

		def word_segmenter_path
			File.join(trained_path, "word-segmenter")
		end
		
		def letter_classifier_path
			File.join(trained_path, "letter-classifier")
		end

		def logging_enabled
			@settings["debug"]
		end
	end
end
