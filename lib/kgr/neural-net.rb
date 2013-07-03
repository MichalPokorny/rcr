module KGR
	class NeuralNet

		def self.image_to_data(image)
			data = []
			(0...image.width).each { |x|
				(0...image.height).each { |y|
					r, g, b = image[x, y]
					puts "#{r} #{g} #{b}"
					data << (r + g + b) / (256 * 3)
				}
			}
		end
	end
end
