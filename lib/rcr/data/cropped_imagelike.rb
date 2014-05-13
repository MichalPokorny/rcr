require 'rcr/data/imagelike'

module RCR
	module Data
		class CroppedImagelike < Imagelike
			def initialize(image, x0, y0, width, height)
				raise ArgumentError if width <= 0 || height <= 0
				@image, @x0, @y0 = image, x0, y0
				@x1 = x0 + width
				@y1 = y0 + height
			end

			def to_image
				@image.crop(@x0, @y0, width, height, lazy: false)
			end

			def [](x, y)
				raise if x + @x0 >= @x1 || y + @y0 >= @y1
				@image[x + @x0, y + @y0] or raise "Unreachable image pixel: #{x+@x0}-#{y+@y0}"
			end

			def width; @x1 - @x0; end
			def height; @y1 - @y0; end
		end
	end
end
