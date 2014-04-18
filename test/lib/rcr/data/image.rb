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

			def test_blob_loading_works
				assert Image.from_blob(File.read(TEST_INPUT)).is_a?(Image)
			end

			def test_pixel_array_loading_works
				data = [
					[ [11, 11, 11], [21, 21, 21], [31, 31, 31] ],
					[ [12, 12, 12], [22, 22, 22], [32, 32, 32] ],
				]
				image = RCR::Data::Image.from_pixel_array
				assert [image.width, image.height] == [3, 2]
				assert image[1,2] == [32, 32, 32]
			end
		end
	end
end
