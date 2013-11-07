require 'rcr/data/imagelike'

class RCR::Data::MergedImagelike < Imagelike
	def initialize(box1, box2)
		@box1, @box2 = box1, box2

		@x0 = [ box1.x0, box2.x0 ].min
		@x1 = [ box1.x1, box2.x1 ].max
		@y0 = [ box1.y0, box2.y0 ].min
		@y1 = [ box1.y1, box2.y1 ].max
	end

	def [](x, y)
		p1 = @box1.absolute_pixel(x, y)
		p2 = @box2.absolute_pixel(x, y)
		(0...3).map { |i| [ p1[i], p2[i] ].min }
	end

	def width; @x1 - @x0; end
	def height; @y1 - @y0; end
end
