module RCR::Marshal
	@@known_classes = {}

	def self.register_class(klass)
		@@known_classes[klass::MARSHAL_ID] = klass
	end

	def self.included(base)
		puts "Registering marshalled class #{base}"
		register_class(base)
	end

	def self.register_all_classes
		require 'rcr/letter_classifier/neural'
		require 'rcr/letter_classifier/input_transformer/basic'
		require 'rcr/letter_classifier/input_transformer/combine'
		require 'rcr/feature_extractor/raw_image'
		require 'rcr/feature_extractor/content_aspect_ratio'
		require 'rcr/language_model/markov_chains'
		require 'rcr/markov_chain'
	end

	register_all_classes

	def save(filename)
		File.open "#{filename}.type", "w" do |file|
			YAML.dump({
				type: self.class::MARSHAL_ID
			}, file)
		end

		save_internal(filename)
	end

	def self.load(filename)
		register_all_classes if @@known_classes.empty?

		yaml = YAML.load_file "#{filename}.type"
		type = yaml[:type] or raise "Unexpected format of type file"
		klass = @@known_classes[type] or raise "Unknown marshaled type: #{type}"

		klass.load_internal(filename)
	end
end
