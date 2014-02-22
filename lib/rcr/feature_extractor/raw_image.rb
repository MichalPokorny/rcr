module RCR
	module FeatureExtractor
		class RawImage
			def initialize(size_x, size_y, guillotine: true, forget_aspect_ratio: true)
				@size_x, @size_y, @guillotine, @forget_aspect_ratio = size_x, size_y, guillotine, forget_aspect_ratio
			end

			def pixel_to_level(r, g, b)
				(r + g + b).to_f / (256 * 3)
			end

			def extract_features(image)
				image = image.guillotine if @guillotine

				if @forget_aspect_ratio
					# Forget aspect ratio
					image.scale!(@size_x, @size_y)
				else
					# Border by white to keep aspect ratio
					image.border_to_and_resize_to_fit!(@size_x, @size_y)
				end

				image.pixels.map { |pixel|
					pixel_to_level(*pixel)
				}
			end

			def output_size
				@size_x * @size_y
			end
		end
	end
end
