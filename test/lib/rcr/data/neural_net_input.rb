require_relative '../../../test_helper'
require 'stringio'

module RCR
	module Data
		class NeuralNetInputTest < Test::Unit::TestCase
			private
			def mock_input
				rnd = Random.new(10001)
				NeuralNetInput.new((1..100).map { (rnd.rand - 0.5) * 1000 })
			end

			public
			def test_raw_data_itempotence
				input = mock_input
				data = input.to_raw_data

				output = NeuralNetInput.from_raw_data(data)

				assert input.data == output.data
			end
		end
	end
end
