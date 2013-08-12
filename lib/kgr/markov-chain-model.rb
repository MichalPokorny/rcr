require 'kgr/markov-chain'

module KGR
	class MarkovChainModel
		def initialize(depth)
			@depth = depth
			@chains = (0..depth).map { |i|
				MarkovChain.new(i)
			}
		end

		# TODO: smoothing?
		def load(data)
			@chains.each { |chain|
				chain.load(data)
			}
		end

		def score(continuation)
			@depth.downto(0) do |depth|
				score = @chains[depth].score(context, continuation)
				return score unless score.nil?
			end
			nil
		end
	end
end
