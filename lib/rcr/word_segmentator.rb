require 'rcr/data/image'
require 'rcr/data/segmentation'
require 'rcr/data/segmentation_box'
require 'rcr/data/masked_imagelike'

module RCR
	module WordSegmentator
		def self.pixel_active(r, g, b)
			r < 127 && g < 127 && b < 127 && r + g + b < 400 # TODO
		end

		def self.segment_by(image, condition)
			marks = (0...image.width).map { (0...image.height).map { false } }

			boxes = []

			(0...image.width).each { |start_x|
				(0...image.height).each { |start_y|
					next if !condition.call(start_x, start_y) || marks[start_x][start_y]

					# First find the bounds of the contiguous area.

					visited = (0...image.width).map { (0...image.height).map { false } }
					visited[start_x][start_y] = true
					queue = [ [start_x, start_y] ]

					x0, x1, y0, y1 = start_x, start_x, start_y, start_y

					until queue.empty?
						x, y = *(queue.shift)

						marks[x][y] = true

						x0 = x if x < x0
						x1 = x if x > x1
						y0 = y if y < y0
						y1 = y if y > y1

						(x-1..x+1).each { |px|
							(y-1..y+1).each { |py|
								next if px < 0 or py < 0 or px >= image.width or py >= image.height
								if !visited[px][py] and condition.call(px, py)
									visited[px][py] = true
									queue << [px, py]
								end
							}
						}
					end

					next if x0 == x1 || y0 == y1 # zero-size blocks are skipped

					block = Data::MaskedImagelike.new(image, marks, x0, x1, y0, y1)
					box = Data::SegmentationBox.new(x0, y0, block)

					boxes << box
				}
			}

			boxes
		end

		def self.load_segmentation_from_sample(image, image_corrections)
			# Red (#ff0000) means "not actually connected"
			# Green (#00ff00) means "actually connected"

			pixel_passable = lambda do |x, y|
				pixel = image_corrections[x, y]

				r, g, b = *pixel

				if r == 0 && g > 127 && b == 0
					# Green, force this pixel.
					# puts "Green: #{x} #{y}"
					return true
				end

				if r > 127 && g == 0 && b == 0
					# Red, skip this pixel.
					# puts "Red: #{x} #{y}"
					return false
				end

				pixel_active(*image[x, y])
			end

			segment_by(image, pixel_passable)
		end

		def self.segment_into_contiguous_parts(image)
			segment_by(image, lambda do |x, y|
				pixel_active(*image[x, y])
			end)
		end
	end
end
