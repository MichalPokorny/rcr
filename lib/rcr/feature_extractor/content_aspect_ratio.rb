module RCR
	module FeatureExtractor
		class ContentAspectRatio
			def extract_features(image)
				clipped = image.guillotine

				[clipped.width.to_f / (clipped.width.to_f + clipped.width.to_f)]
			end

			MARSHAL_ID = self.name
			include Marshal

			def save_internal(filename)
				# nop
			end

			def self.load_internal(filename)
				self.new
			end
		end
	end
end
