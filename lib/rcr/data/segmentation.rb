require 'rcr/logging'
require 'rcr/data/image'
require 'chunky_png'

module RCR
	module Data
		class Segmentation
			include Logging

			def initialize(image, boxes)
				@image = image
				@boxes = boxes
			end

			def detected_text(letter_classifier)
				@boxes.sort_by(&:x0).map { |box|
					letter_classifier.classify(box.image)
				}.join
			end

			def draw_on_image!(image)
				colors = [ Image::RED, Image::GREEN, Image::BLUE ]
				color_index = 0

				@boxes.each do |box|
					log "Drawing box: #{box}"
					image.draw_rectangle!(box.x0, box.y0, box.x1, box.y1, colors[color_index])
					color_index = (color_index + 1) % colors.length
				end
			end

			protected
			def find_box_index_of_pixel(px, py)
				@boxes.each_index do |i|
					box = @boxes[i]
					return i if box.maybe_covers_pixel?(px, py) && box.pixel_actually_present?(px, py)
				end

				nil
			end

			def find_box_of_pixel(px, py)
				index = find_box_index_of_pixel(px, py)
				index ? @boxes[index] : nil
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

			def active_pixels_in_rect(x0, x1, y0, y1)
				# TODO: make it faster?
				pixels = []
				(x0...x1).each do |x|
					(y0...y1).each do |y|
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

				# TODO: cheat. let violations be the size of the difference between those
				# boxes. let it be sizeof(hull) - sizeof(A) - sizeof(B) +
				# sizeof(intersection)
				active.each_index do |i|
					p1 = active[i]

					box_a = find_box_of_pixel(*p1)
					box_b = other.find_box_of_pixel(*p1)

					xs = [ box_a.x0, box_a.x1 ]
					xs << box_b.x0 << box_b.x1 if box_b
					ys = [ box_a.y0, box_a.y1 ]
					xs << box_b.y0 << box_b.y1 if box_b
					# Just the hull. Doesn't make sense to look for violations anywhere else.
					x0, x1, y0, y1 = xs.min, xs.max, ys.min, ys.max

					active_pixels_in_rect(x0, x1, y0, y1).each do |p2|
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

				# TODO: this is a slow thing to do. think of something better.
				300.times do
					p1 = active[rand(active.size)]
					p2 = active[rand(active.size)]

					if pixels_in_same_box?(p1, p2) ^ other.pixels_in_same_box?(p1, p2)
						diff += 1
					end
				end

				diff.to_f / (active.size ** 2)
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
