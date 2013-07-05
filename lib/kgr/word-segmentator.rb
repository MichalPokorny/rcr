require 'kgr/data/image'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'

module KGR
	module WordSegmentator
		def self.pixel_active(r, g, b)
			r + g + b < 400 # TODO
		end

		def self.segment_into_continuous_parts(image)
			marks = (0...image.width).map { (0...image.height).map { false } }

			boxes = []

			(0...image.width).each { |start_x|
				(0...image.height).each { |start_y|
					next if !pixel_active(*image[start_x, start_y]) || marks[start_x][start_y]

					# First find the bounds of the continuous area.

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
								if !visited[px][py] and pixel_active(*image[px, py])
									visited[px][py] = true
									queue << [px, py]
								end
							}
						}
					end

					block = (x0...x1).map { |ix|
						(y0...y1).map { |iy|
							image[ix, iy]
						}
					}

					next if block.size == 0 # zero-size blocks are skipped

					block = Data::Image.from_pixel_block(block)
					box = Data::SegmentationBox.new(x0, y0, block)
					
					boxes << box
				}
			}

			boxes
		end
	end
end
