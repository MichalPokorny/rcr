module KGR
	module HeuristicOversegmenter
		class Oversegmentation
			def initialize(image, xs, graph)
				@image, @xs, @graph = image, xs, graph
			end

			attr_reader :xs, :graph

			# TODO: find best path for word

			def best_path(score_calculator)
				# Viterbi algorithm
				scores = {}
				scores[0] = 1
				path = {}

				context = {}
				context[0] = []

				puts "oversegmentation xs: #{xs}"
				puts "graph: #{graph}"

				xs.each_index do |i|
					for j in graph[i]
						result, edge_score = score_calculator.calculate_score(context[i], image, xs[i], xs[j])
						score = scores[i] * edge_score
						if scores[j].nil? || scores[j] < score
							scores[j], path[j] = score, i 
							context[j] = context[i] + [ result ]
						end
					end
				end
				
				# TODO: mayhaps don't oversegment whole?
				best_path = []
				point = xs.length - 1
				until point.nil?
					best_path << point
					point = path[point]
				end

				best_path = best_path.map { |i| xs[i] }.sort

				best_path
			end
		end
	end
end
