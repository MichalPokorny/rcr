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

			def test_basic
				input = NeuralNetInput.new([0.1, 0.2, 0.3])
				assert input == NeuralNetInput.new([0.1, 0.2, 0.3])
				assert NeuralNetInput.concat(input, NeuralNetInput.new([0.4, 0.5])) == NeuralNetInput.new([0.1, 0.2, 0.3, 0.4, 0.5])
			end
		end
	end
end
