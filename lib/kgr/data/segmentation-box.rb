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

			def self.merge(box1, box2)
				x0 = [ box1.x0, box2.x0 ].min
				x1 = [ box1.x1, box2.x1 ].max
				y0 = [ box1.y0, box2.y0 ].min
				y1 = [ box1.y1, box2.y1 ].max

				width = x1 - x0
				height = y1 - y0

				pixels = (0...width).map { |x|
					(0...height).map { |y|
						p1 = box1.absolute_pixel(x, y)
						p2 = box2.absolute_pixel(x, y)
						(0...3).map { |i| [ p1[i], p2[i] ].min }
					}
				}

				image = Data::Image.from_pixel_block(pixels)
				self.new(x0, y0, image)
			end

			def split_along_relative_x(split_x)
				pixels_left = (0...split_x).map { |x|
					(0...height).map { |y|
						image[x, y]
					}
				}
				pixels_right = (split_x...width).map { |x|
					(0...height).map { |y|
						image[x, y]
					}
				}

				image_left = Data::Image.from_pixel_block(pixels_left)
				image_right = Data::Image.from_pixel_block(pixels_right)

				a = self.class.new(x0, y0, image_left)
				b = self.class.new(x0 + split_x, y0, image_right)

				[ a, b ]
			end
		end
	end
end
