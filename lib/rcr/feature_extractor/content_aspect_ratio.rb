module RCR
	module FeatureExtractor
		class ContentAspectRatio
			def extract_features(image)
				clipped = image.guillotine

				[clipped.width.to_f / (clipped.width.to_f + clipped.width.to_f)]
			end
		end
	end
end
