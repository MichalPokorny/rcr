require 'rcr/data/image'
require 'rcr/data/segmentation'
require 'rcr/data/segmentation_box'
require 'rcr/word_segmentator'

module RCR
	module WordSegmentator
		class SimpleContiguousParts
			def segment(image)
				result = WordSegmentator.segment_into_contiguous_parts(image)
				Data::Segmentation.new(image, result)
			end
		end
	end
end
