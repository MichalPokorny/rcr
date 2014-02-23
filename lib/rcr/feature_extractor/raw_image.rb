module RCR
	module FeatureExtractor
		class RawImage
			def initialize(size_x, size_y, guillotine: true, forget_aspect_ratio: true, normalize_contrast: true)
				@size_x, @size_y, @guillotine, @forget_aspect_ratio, @normalize_contrast = size_x, size_y, guillotine, forget_aspect_ratio, normalize_contrast
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

				levels = image.pixels.map { |pixel| pixel_to_level(*pixel) }

				if @normalize_contrast
					min, max = levels.min, levels.max
					levels.map! { |level| (level - min) / (max - min) } if min < max
				end

				levels
			end

			def output_size
				@size_x * @size_y
			end

			MARSHAL_ID = self.name
			include Marshal

			def save_internal(filename)
				File.open filename, "w" do |file|
					YAML.dump({
						size_x: @size_x, size_y: @size_y, guillotine: @guillotine, forget_aspect_ratio: @forget_aspect_ratio, normalize_contrast: @normalize_contrast
					}, file)
				end
			end

			def self.load_internal(filename)
				hash = YAML.load_file(filename)
				self.new(hash.delete(:size_x), hash.delete(:size_y), hash)
			end
		end
	end
end
