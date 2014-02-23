require 'rcr/marshal'
require 'rcr/data/neural-net-input'
require 'rcr/feature_extractor/raw_image'

module RCR
	module LetterClassifier
		module InputTransformer
			class Basic
				def self.create(*args)
					self.new(RCR::FeatureExtractor::RawImage.new(16, 16, *args))
				end

				def initialize(feature_extractor)
					@feature_extractor = feature_extractor
				end

				def output_size
					@feature_extractor.output_size
				end

				def transform(image)
					Data::NeuralNetInput.new(@feature_extractor.extract_features(image))
				end

				MARSHAL_ID = self.name
				include Marshal

				def save_internal(filename)
					@feature_extractor.save("#{filename}.feature-extractor")
				end

				def self.load_internal(filename)
					self.new(Marshal.load("#{filename}.feature-extractor"))
				end
			end
		end
	end
end
