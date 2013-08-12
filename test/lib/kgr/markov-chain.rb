require_relative '../../test_helper'

module KGR
	class MarkovChainTest < Test::Unit::TestCase
		def test_works
			mc = MarkovChain.new(2)
			mc.load([
				0, 1, 2, 0, 1, 2, 0, 1, 3
			])

			assert mc.dict.key?([0,1])
			assert mc.dict[[0,1]].key?(2)

			assert (mc.score([0,1], 2) - 0.6666).abs < 0.001
			assert (mc.score([0,1], 3) - 0.3333).abs < 0.001
		end
	end
end
