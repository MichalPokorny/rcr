require_relative '../../../test_helper'

module RCR
	module Data
		class ImageTest < Test::Unit::TestCase
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")

			def test_loading_works
				# Handle both ChunkyPNG and RMagick images
				assert Image.new(ChunkyPNG::Image.from_file(TEST_INPUT)).is_a?(Image)
				assert Image.new(Magick::Image.read(TEST_INPUT).first).is_a?(Image)

				# And allow loading.
				assert Image.load(TEST_INPUT).is_a?(Image)
			end
		end
	end
end
