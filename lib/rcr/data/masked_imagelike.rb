require 'rcr/data/imagelike'

module RCR
	module Data
		class MaskedImagelike < Imagelike
			def initialize(image, mask, x0, x1, y0, y1)
				@image, @mask = image, mask
				@x0, @x1, @y0, @y1 = x0, x1, y0, y1
			end

			def [](x, y)
				ix, iy = x + @x0, y + @y0
				raise if ix >= @x1 || iy >= @y1
				if @mask[ix][iy]
					@image[ix, iy]
				else
					[ 255, 255, 255 ]
				end
			end

			def width; @x1 - @x0; end
			def height; @y1 - @y0; end
		end
	end
end
