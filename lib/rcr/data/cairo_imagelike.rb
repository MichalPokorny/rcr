require 'rcr/data/imagelike'

module RCR
	module Data
		class CairoImagelike < Imagelike
			def initialize(surface)
				@surface = surface
			end

			private
			def pixel_data
				@pixel_data ||= @surface.data
			end

			public
			def [](x, y)
				# Know just CAIRO_FORMAT_ARGB32
				raise "Unknown Cairo format" unless @surface.format == 0
				start = (y * @surface.stride) + (x * 4)
				data = pixel_data[start...start + 4].reverse

				# TODO: those are stored native-endian! this just happens to be
				# little-endian on my machine!
				data[1..3].each_char.map(&:ord)
			end

			def width; @surface.width; end
			def height; @surface.height; end
		end
	end
end
