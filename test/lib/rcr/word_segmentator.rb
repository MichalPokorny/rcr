require_relative '../../test_helper'
require 'stringio'

require 'rcr/data/image'

module RCR
	class WordSegmentatorTest < Test::Unit::TestCase
		def test_active_works_well
			assert !WordSegmentator.pixel_active(255, 0, 0)
			assert !WordSegmentator.pixel_active(0, 255, 0)
			assert WordSegmentator.pixel_active(0, 0, 0)
		end

		TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")
		def test_segment_into_contiguous_parts_works
			image = Data::Image.load(TEST_INPUT)
			assert WordSegmentator.segment_into_contiguous_parts(image).is_a?(Array)
		end
	end
end
