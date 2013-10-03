require 'kgr/data/imagelike'

module KGR
	module Data
		class CroppedImagelike < Imagelike
			def initialize(image, x0, x1, y0, y1)
				@image, @x0, @x1, @y0, @y1 = image, x0, x1, y0, y1
			end

			def [](x, y)
				raise if x + @x0 >= @x1 || y + @y0 >= y1
				@image[x + @x0, y + @y0]
			end

			def width; @x1 - @x0; end
			def height; @y1 - @y0; end
		end
	end
end
