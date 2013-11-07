require 'rcr/data/image'
require 'rcr/data/segmentation'
require 'rcr/data/segmentation-box'
require 'rcr/word-segmentator'

module RCR
	module WordSegmentator
		class SimpleContiguousParts
			def save(filename)
				# stub
			end

			def self.load(filename)
				# stub
				self.new
			end

			# Returns Segmentation
			def segment(image)
				result = WordSegmentator.segment_into_contiguous_parts(image)
				Data::Segmentation.new(image, result)
			end
		end
	end
end
