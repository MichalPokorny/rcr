module KGR
	class NeuralNet
		QUANTUMS = 10

		def self.image_to_data(image)
			data = []
			(0...image.width).each { |x|
				(0...image.height).each { |y|
					r, g, b = image[x, y]
					value = (r + g + b) / ((256 * 3) / QUANTUMS)
					# print value.to_s(16)
					data << value
				}
				# puts
			}
		end
	end
end
