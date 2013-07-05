module KGR
	module Data
		class SegmentationBox
			def initialize(x, y, image)
				@x = x
				@y = y
				@image = image
			end

			def width; @image.width; end
			def height; @image.height; end

			attr_reader :x, :y, :image

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
