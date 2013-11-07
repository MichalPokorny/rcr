require 'rcr/markov-chain'

class RCR::MarkovChainModel
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

	def score(context, continuation)
		@depth.downto(0) do |depth|
			next if context.length < depth
			score = @chains[depth].score(context, continuation)
			return score unless score.nil?
		end
		nil
	end

	def self.load_from_corpus(depth, path)
		model = self.new(depth)
		model.load(File.read(path).each_char.select { |c| c =~ /[a-zA-Z0-9]/ }) # TODO: bad position.
		model
	end
end
