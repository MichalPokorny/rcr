require 'kgr/data/image'
require 'chunky_png'

module KGR
	module Data
		class Segmentation
			def initialize(image, boxes)
				@image = image
				@boxes = boxes
			end

			def text
				"TODO" # TODO
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

			attr_reader :image, :boxes
		end
	end
end
