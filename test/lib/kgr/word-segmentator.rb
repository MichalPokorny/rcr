require_relative '../../test_helper'
require 'stringio'

module KGR
	class WordSegmentatorTest < Test::Unit::TestCase
		def test_active_works_well
			assert !WordSegmentator.pixel_active(255, 0, 0)
			assert !WordSegmentator.pixel_active(0, 255, 0)
			assert WordSegmentator.pixel_active(0, 0, 0)
		end
	end
end
