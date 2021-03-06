require_relative '../../test_helper'

module RCR
	class MarkovChainTest < Test::Unit::TestCase
		def test_works
			mc = MarkovChain.new(2)
			mc.train([0, 1, 2, 0, 1, 2, 0, 1, 3])

			assert mc.dict.key?([0,1])
			assert mc.dict[[0,1]].key?(2)

			assert (mc.score([0,1], 2) - 0.6666).abs < 0.001
			assert (mc.score([0,1], 3) - 0.3333).abs < 0.001
		end

		def test_docs
			mc = MarkovChain.new(2)
			mc2 = MarkovChain.new(2, { "AB" => { "C" => 0.7, "A" => 0.3 } })

			mc.train("ABC ABD ABA ABC ABC")
			assert_equal 0.6, mc.score("AB".chars, "C")
		end
	end
end
