require_relative '../../../test_helper'

module RCR
	module Data
		class ImageTest < Test::Unit::TestCase
			TEST_INPUT = File.join(TEST_DATA_PATH, "letter", "letter.png")
			TMP_IMAGE_PATH = File.join(TEST_DATA_PATH, "array_image.png")

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
				image = RCR::Data::Image.from_pixel_array(data)
				assert [image.width, image.height] == [3, 2]
				assert image[2,1] == [32, 32, 32]

				FileUtils.rm_f(TMP_IMAGE_PATH)
				image.save(TMP_IMAGE_PATH)
				assert File.exist?(TMP_IMAGE_PATH)
				FileUtils.rm_f(TMP_IMAGE_PATH)

				scaled = image.scale(10, 10)
				assert scaled.width == 10 && scaled.height == 10
			end
		end
	end
end
