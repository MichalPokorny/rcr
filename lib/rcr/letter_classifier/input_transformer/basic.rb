require 'rcr/data/neural-net-input'
require 'rcr/feature_extractor/raw_image'

module RCR
	module LetterClassifier
		module InputTransformer
			class Basic
				def initialize(guillotine: true, forget_aspect_ratio: true)
					@feature_extractor = RCR::FeatureExtractor::RawImage.new(16, 16, guillotine: guillotine, forget_aspect_ratio: forget_aspect_ratio)
				end

				def output_size
					@feature_extractor.output_size
				end

				def transform(image)
					Data::NeuralNetInput.new(@feature_extractor.extract_features(image))
				end
			end
		end
	end
end
