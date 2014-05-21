require 'rcr/markov_chain'
require 'rcr/language_model/base'

# TODO: don't ignore character size?
module RCR
	module LanguageModel
		class MarkovChains < Base
			def initialize(depth, chains = nil)
				@depth = depth
				@chains = chains || (0..depth).map { |i|
					MarkovChain.new(i)
				}
			end

			# TODO: smoothing?
			def train(data)
				@chains.each { |chain|
					chain.train(data)
				}
			end

			def score_prefix_continuations(context, continuations)
				context = context.upcase.each_char.to_a
				continuations = continuations.map(&:upcase)

				# Find first chain that has an opinion about every letter in the 
				@depth.downto(0) do |depth|
					next if context.length < depth
					scores = {}
					continuations.each do |continuation|
						scores[continuation] = @chains[depth].score(context, continuation)
					end

					return scores if scores.values.none?(&:nil?)
				end

				# Last resort: return uniform distribution (unknown letter)
				Hash[continuations.map { |c| [c, 1.0 / continuations.size] }]
			end

			MARSHAL_ID = self.name
			include Marshal

			def save_internal(filename)
				File.open filename, "w" do |file|
					YAML.dump({
						depth: @depth
					}, file)
				end

				@chains.each.with_index do |chain, i|
					chain.save("#{filename}-#{i}")
				end
			end

			def self.load_internal(filename)
				hash = YAML.load_file(filename)
				self.new(hash[:depth], (0..hash[:depth]).map { |d|
					Marshal.load("#{filename}-#{d}")
				})
			end
		end
	end
end
