require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'

module KGR
	module WordSegmentator
		class Default
			def save(filename)
				# stub
			end

			def self.load(filename)
				# stub
				self.new
			end

			# Returns Segmentation
			def segment(image)
				result = []

				result << Data::SegmentationBox.new(image, image.width / 2, image.height / 2, image.width / 4, image.height / 4)

				Data::Segmentation.new(image, result)
			end
		end
	end
end
