module KGR
	module Data
		class Imagelike
			def to_image
				image = ChunkyPNG::Image.new(imagelike.width, imagelike.height, ChunkyPNG::Color::TRANSPARENT)
				(0...imagelike.width).map { |x|
					(0...imagelike.height).map { |y|
						image[x, y] = ChunkyPNG::Color.rgb(*imagelike[x, y])
					}
				}
				self.new(image)
			end
		end
	end
end
