require_relative '../../../test_helper'

module RCR
	module Data
		class DatasetTest < Test::Unit::TestCase
			def test_basic
				dataset = RCR::Data::Dataset.new([
					[[0.1, 0.1], 0.2], [[0.3, 0.5], 0.8], [[-0.5, 0.5], 0.0], [[0.1, -0.3], -0.2]
				])

				assert dataset.input_type == Array && dataset.expected_output_type == Float

				dataset2 = RCR::Data::Dataset.new({
					0.0 => [[-0.1, 0.1], [0.0, 0.0], [0.5, -0.5]],
					0.5 => [[-0.1, 0.6], [0.4, 0.1], [0.2, 0.3]],
					-0.5 => [[-0.2, -0.3], [0.2, -0.7], [-0.9, 0.4]],
				})
			end

			def test_transformations
				dataset = RCR::Data::Dataset.new([[1, 5], [2, 10], [3, 15]])
				dataset2 = dataset.transform_inputs { |x| x * 5}.transform_expected_outputs { |y| y / 5 }
				assert dataset2 == RCR::Data::Dataset.new([[5, 1], [10, 2], [15, 3]])
			end
		end
	end
end
