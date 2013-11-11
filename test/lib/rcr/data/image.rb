require_relative '../../../test_helper'

module RCR
	module Data
		class ImageTest < Test::Unit::TestCase
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

			def test_loading_works
				assert Image.new(TEST_INPUT).is_a?(Image)
			end
		end
	end
end
