module RCR::Marshal
	@@known_classes = {}

	def self.register_class(klass)
		@@known_classes[klass::MARSHAL_ID] = klass
	end

	def self.register_all_classes
		require 'rcr/letter_classifier/neural'
		register_class(RCR::LetterClassifier::Neural)
	end

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
