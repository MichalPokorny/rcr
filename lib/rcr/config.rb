require 'pathname'
require 'yaml'

module RCR
	class Config
		def self.instance
			@instance ||= self.load
		end

		def self.load
			path = Pathname.new("~/.rcr-config.yml").expand_path
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
			raise InvalidConfiguration, "No data directory defined." unless @settings.key?("data_directory")
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

		def segmentation_inputs_path
			input_path.join("segment")
		end
	end
end
