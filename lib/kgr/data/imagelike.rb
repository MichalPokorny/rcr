require 'kgr/data/image'

module KGR
	module Data
		class Imagelike
			def to_image
				puts "Converting imagelike of size #{width}x#{height} to image"
				image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
				(0...width).map { |x|
					(0...height).map { |y|
						image[x, y] = ChunkyPNG::Color.rgb(*self[x, y])
					}
				}
				Image.new(image)
			end

			[:guillotine].each do |symbol|
				define_method symbol do |*args|
					to_image.send(symbol, *args)
				end
			end
		end
	end
end
