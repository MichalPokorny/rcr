require 'kgr/data/image'
require 'chunky_png'

module KGR
	module Data
		class Segmentation
			def initialize(image, boxes)
				@image = image
				@boxes = boxes
			end

			def detected_text(letter_classifier)
				@boxes.sort_by(&:x0).map { |box|
					letter_classifier.classify(box.image).chr
				}.join
			end

			def draw_on_image!(image)
				colors = [ Image::RED, Image::GREEN, Image::BLUE ]
				color_index = 0

				@boxes.each do |box|
					puts "Drawing box: #{box}"
					image.draw_rectangle!(box.x0, box.y0, box.x1, box.y1, colors[color_index])
					color_index = (color_index + 1) % colors.length
				end
			end

			private
			def find_box_index_of_pixel(px, py)
				@boxes.each_index do |i|
					box = @boxes[i]
					return i if box.maybe_covers_pixel?(px, py) && box.pixel_actually_present?(px, py)
				end

				nil
			end

			public
			def pixel_active?(px, py)
				find_box_index_of_pixel(px, py) != nil
			end

			def width; image.width; end
			def height; image.height; end

			# The number of pixel box discrepancies will be useful for comparing
			# segmentations...
			def pixels_in_same_box?(pixel1, pixel2)
				box1 = find_box_index_of_pixel(*pixel1)
				box2 = find_box_index_of_pixel(*pixel2)
				box1 == box2
			end

			attr_reader :image, :boxes

			def to_raw_data
				bytes = [ @boxes.length ].pack("Q")
				@boxes.each { |box|
					box_data = box.to_raw_data

					bytes += [ box_data.length ].pack("Q")
					bytes += box_data
				}
				bytes += @image.to_raw_data
				bytes
			end

			def self.from_raw_data(data)
				bytes = data[0...8]
				ary = bytes.unpack("Q")
			
				data = data[8...data.size]

				boxes = []

				ary[0].times do
					bytes = data[0...8]
					ary = bytes.unpack("Q")

					data = data[8...data.size]

					boxes << Data::SegmentationBox.from_raw_data(data[0...ary.first])

					data = data[ary.first...data.size]
				end

				image = Data::Image.from_raw_data(data)

				self.new(image, boxes)
			end

			def active_pixels
				pixels = []
				(0...width).each do |x|
					(0...height).each do |y|
						if pixel_active?(x, y)
							pixels << [ x, y ]
						end
					end
				end
				pixels
			end

			def difference_exact(other)
				active = active_pixels
				diff = 0

				active.each_index do |i|
					(0...i).each do |j|
						p1, p2 = active[i], active[j]
						if pixels_in_same_box?(p1, p2) ^ other.pixels_in_same_box?(p1, p2)
							diff += 1
						end
					end
				end

				diff.to_f / (active.size ** 2)
			end

			def difference_approximate(other)
				active = active_pixels
				diff = 0

				1000.times do
					p1 = active[rand(active.size)]
					p2 = active[rand(active.size)]

					if pixels_in_same_box?(p1, p2) ^ other.pixels_in_same_box?(p1, p2)
						diff += 1
					end
				end

				diff
			end

			def difference(other)
				difference_approximate(other)
			end

			# Returns a modified Segmentation
			def merge_boxes(box1, box2)
				raise ArgumentError unless @boxes.include?(box1) && @boxes.include?(box2)
				raise if box1 == box2
				boxes = @boxes.reject { |box| box == box1 || box == box2 } << SegmentationBox.merge(box1, box2)
				raise unless boxes.count == @boxes.count - 1
				self.class.new(@image, boxes)
			end

			def remove_box(box)
				raise ArgumentError unless @boxes.include?(box)
				self.class.new(@image, @boxes.reject { |b| b == box})
			end

			def split_box_along_relative_x(box, relative_x)
				raise ArgumentError unless @boxes.include?(box)
				self.class.new(@image, @boxes.reject { |b| b == box } +
					box.split_along_relative_x(relative_x))
			end
		end
	end
end