require 'kgr/data/image'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'
require 'kgr/word-segmentator'

module KGR
	module WordSegmentator
		class Stupid
			def save(filename)
				# stub
			end

			def self.load(filename)
				# stub
				self.new
			end

			# Returns Segmentation
			def segment(image)
				result = WordSegmentator.segment_into_continuous_parts(image)
				Data::Segmentation.new(image, result)
			end
		end
	end
end
