require_relative '../../../test_helper'

module RCR
	module Data
		class DatasetTest < Test::Unit::TestCase
			def test_transformations
				dataset = RCR::Data::Dataset.new([[1, 5], [2, 10], [3, 15]])
				dataset2 = dataset.transform_inputs { |x| x * 5}.transform_expected_outputs { |y| y / 5 }
				assert dataset2 == RCR::Data::Dataset.new([[5, 1], [10, 2], [15, 3]])
			end
		end
	end
end
