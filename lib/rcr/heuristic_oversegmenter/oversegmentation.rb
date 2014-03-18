require 'rcr/logging'

module RCR
	module HeuristicOversegmenter
		class Oversegmentation
			include Logging

			class Edge
				# detected letter, score, left X, right X
				attr_accessor :letter, :score, :x0, :x1

				def initialize(x0, x1, letter, score)
					@x0, @x1, @letter, @score = x0, x1, letter, score
				end
			end

			def initialize(image, xs, edges)
				@image, @xs, @edges = image, xs, edges
			end

			attr_reader :xs, :edges

			def edges_from_x(x)
				# TODO: slow
				edges.select { |edge| edge.x0 == x }
			end

			def best_path
				best_path_with_score[0]
			end

			def best_path_for_lengths
				# Viterbi algorithm
				scores = {} # x => { length => score }
				paths = {} # x => { length => array }

				scores[xs[0]] = { 0 => 1 }
				paths[xs[0]] = { 0 => [] }

				for x0 in xs
					for prefix_length in scores[x0].keys
						edges_from_x(x0).each do |edge|
							score = scores[x0][prefix_length] * edge.score

							scores[edge.x1] ||= {}
							paths[edge.x1] ||= {}

							if scores[edge.x1][prefix_length + 1].nil? ||
								scores[edge.x1][prefix_length + 1] < score
								scores[edge.x1][prefix_length + 1],
									paths[edge.x1][prefix_length + 1] =
										score, paths[edge.x0][prefix_length].dup << edge
							end
						end
					end
				end

				Hash[
					scores[xs.last].keys.map { |k|
						[k, [paths[xs.last][k], scores[xs.last][k]]]
					}
				]
			end

			def best_path_with_score
				# Viterbi algorithm
				scores = {}
				scores[xs[0]] = 1

				path = {}
				path[xs[0]] = []

				#context = {}
				#context[xs[0]] = []

				log "oversegmentation xs: #{xs}"

				# TODO: suboptimal: O(n^2) space complexity
				for x0 in xs
					next unless scores[x0]
					edges_from_x(x0).each do |edge|
						score = scores[x0] * edge.score

#						if edge.score < 0.01
#							puts "hack"
#							next
#						end
#
#						# XXX HACK HACK
#						if edge.x1 - edge.x0 > @image.height
#							puts "hackety hack"
#							score /= ((edge.x1 - edge.x0) / @image.height) ** 2
#						end

						if scores[edge.x1].nil? || scores[edge.x1] < score
							scores[edge.x1], path[edge.x1] = score, path[edge.x0].dup << edge
							# context[edge.x1] = context[edge.x0] + [edge.letter]
						end
					end
				end

				# TODO: mayhaps don't require oversegmenting the whole image?
				[ path[xs.last], scores[xs.last] ] # .map { |edge| edge.letter }.join('')
			end

			def best_path_of_word_with_score(word)
				# TODO: suboptimal

				log "searching for best path of #{word}, xs=#{xs}"

				scores = {} # TODO: provide context as well?
				scores[xs[0]] = 1

				paths = {}
				paths[xs[0]] = []

				word.each_char do |c|
					scores_new = {}
					paths_new = {}
					for left in xs
						if scores[left].nil? || scores[left] == 0
							log "(skip #{left}->...)"
							next
						end

						good_edges = edges_from_x(left).select { |edge| edge.letter == c }

						if good_edges.empty?
							log "(#{left} has no good edges with #{c})"
							next
						end

						good_edges.each do |edge|
							# TODO: context?
							log "** #{edge.x0}..#{edge.x1} = #{edge.letter} ws. #{edge.score}"

							score = scores[left] * edge.score

							if scores_new[edge.x1].nil? || scores_new[edge.x1] < score
								scores_new[edge.x1], paths_new[edge.x1] = score, paths[edge.x0] + [edge]
							end
						end
					end

					scores = scores_new
					paths = paths_new

					log "..#{c} ==>"
					xs.each do |i|
						next if scores[i].nil? || scores[i] == 0
						log "#{i}: #{scores[i]}"
					end
					log "..........."
				end

				log "best path of word: #{paths[xs.last].inspect}"
				[ paths[xs.last], scores[xs.last] ]
			end

			# TODO: this shouldn't ever be used anywhere!
			def self.build_from_xs(image, letter_classifier, xs, y0 = nil, y1 = nil)
				xs = xs.sort
				log "building from xs: #{xs}"
				y0 ||= 0
				y1 ||= image.height
				edges = []
				xs.each_index do |i|
					for j in (i+1)...xs.length
						if xs[j] - xs[i] < (y1 - y0) * 2
							width = xs[j] - xs[i]
							height = y1 - y0
							# puts "cropping: #{xs[i]} through #{xs[j]}: width #{width}, height #{height}, original size #{image.width}x#{image.height}"
							result = letter_classifier.classify_with_alternatives(image.crop(xs[i], y0, width, height))

							# TODO: settable. this takes top 5 candidates.
							candidates = result.keys.sort { |a,b| result[b] <=> result[a] } #.take(5)
							# puts "candidates #{xs[i]}..#{xs[j]}: #{candidates.map { |c| "#{c}(%.2f)" % result[c] }.join('; ')}"

							# Normalize results
							sum = candidates.map { |letter| result[letter] }.inject(&:+)
							candidates.each do |letter|
								edges << Oversegmentation::Edge.new(xs[i], xs[j], letter, result[letter] / sum)
							end
						end
					end
				end

				#puts "built edges: #{edges.map { |e| "#{e.x0}->#{e.x1}" }.join(" ")}"

				Oversegmentation.new(image, xs, edges)
			end
		end
	end
end
