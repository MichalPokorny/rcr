require 'kgr/data/image'

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

			def maybe_covers_pixel?(px, py)
				x0 <= px && y0 <= py && x1 > px && y1 > py
			end

			def pixel_actually_present?(px, py)
				raise unless maybe_covers_pixel?(px, py)

				ax, ay = px - x0, py - y0
				
				# TODO!
				r, g, b = *image[ax, ay]
				r < 127 && g < 127 && b < 127 && r + g + b < 400
			end

			def x0; x; end
			def y0; y; end
			def x1; x + width; end
			def y1; y + height; end

			def absolute_pixel(x, y)
				if maybe_covers_pixel?(x, y)
					image[x - x0, y - y0]
				else
					[ 255, 255, 255 ] # pixel not present: white
				end
			end

			def to_raw_data
				[ x, y ].pack("QQ") + image.to_raw_data
			end

			def self.from_raw_data(data)
				x, y = data[0...16].unpack("QQ")
				data = data[16...data.size]

				self.new(x, y, Data::Image.from_raw_data(data))
			end

			class MergedImagelike
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

			def self.merge(box1, box2)
				image = Data::Image.from_imagelike(MergedImagelike.new(box1, box2))
				self.new(x0, y0, image)
			end

			class CroppedImagelike
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

			def split_along_relative_x(split_x)
				left = CroppedImagelike.new(image, 0, 0, split_x, height)
				right = CroppedImagelike.new(image, split_x, 0, width, height)

				a = self.class.new(x0, y0, Data::Image.from_imagelike(left))
				b = self.class.new(x0 + split_x, y0, Data::Image.from_imagelike(right))

				[ a, b ]
			end
		end
	end
end
