require 'rcr/data/imagelike'

module RCR
	module Data
		class PixmapImagelike < Imagelike
			def initialize(pixmap)
				@pixmap = pixmap
			end

			protected
			def image
				@image ||= @pixmap.get_image(0, 0, *@pixmap.size)
			end

			public
			def [](x, y)
				pixel = image.get_pixel(x, y)
				b = pixel & 0xFF; pixel >>= 8
				g = pixel & 0xFF; pixel >>= 8
				r = pixel & 0xFF
				[r, g, b]
			end

			def width; image.width; end
			def height; image.height; end
		end
	end
end
