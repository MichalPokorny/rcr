module KGR
	class NeuralNet
		QUANTUMS = 10

		def self.image_to_data(image)
			scaled = image.guillotine
			scaled.scale!(16,16)
			
			data = []
			(0...scaled.width).each { |x|
				(0...scaled.height).each { |y|
					r, g, b = scaled[x, y]
					value = (r + g + b) / ((256 * 3) / QUANTUMS)
					value /= QUANTUMS.to_f
					data << value
				}
			}

			data
		end
	end
end
