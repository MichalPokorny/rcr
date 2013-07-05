module KGR
	module Data
		class SegmentationBox
			def initialize(image, x, y, width, height)
				@x = x
				@y = y
				@width = width
				@height = height
				@image = image.crop(@x, @y, @width, @height)
			end

			attr_reader :x, :y, :width, :height, :image

			def to_s
				"Box<(#{x};#{y}) #{width}x#{height}>"
			end

			def x0; x; end
			def y0; y; end
			def x1; x + width; end
			def y1; y + height; end
		end
	end
end
