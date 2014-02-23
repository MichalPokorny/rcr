require 'rcr/markov_chain'
require 'rcr/language_model/base'

# TODO: don't ignore character size?
# TODO: use Marshal
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

			def score(context, continuation)
				context = context.upcase.each_char.to_a
				continuation = continuation.upcase

				@depth.downto(0) do |depth|
					next if context.length < depth
					score = @chains[depth].score(context, continuation)
					return score unless score.nil?
				end
				nil
			end

			def self.train_from_corpus(depth, path)
				model = self.new(depth)
				model.train(File.read(path).each_char.select { |c| c =~ /[a-zA-Z0-9]/ }.map(&:upcase)) # TODO: bad position.
				model
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
