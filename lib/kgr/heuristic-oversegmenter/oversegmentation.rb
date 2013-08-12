module KGR
	module HeuristicOversegmenter
		class Oversegmentation
			def initialize(xs, graph)
				@xs, @graph = xs, graph
			end

			attr_reader :xs, :graph
		end
	end
end
