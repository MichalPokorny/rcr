require 'kgr/data/image'
require 'kgr/heuristic-oversegmenter/oversegmentation'

module KGR
	module HeuristicOversegmenter
		# Oversegments by X coordinates of continuous blocks and by a regular
		# interval.
		#
		# More heuristics: local minimum of ink height, local minimum in vertical
		# projection
		class Stupid
			def initialize
			end

			# Returns list of X coordinates to oversegment the image at.
			def oversegment(image)
				# TODO: mayhaps move the method somewhere else?
				parts = WordSegmentator.segment_into_continuous_parts(image)
				return [] if parts.empty?

				xs = parts.map(&:x0) + parts.map(&:x1)
				x0, x1 = xs.min, xs.max
				y0, y1 = parts.map(&:y0).min, parts.map(&:y1).max
				step = (y1 - y0) / 4

				xs += (x0..x1).step(step).to_a
				xs.sort!.uniq!

				graph = {}
				xs.each_index do |i|
					graph[i] = []
					# Stupid. Stupid. Stupid. Stupid.
					for j in (i+1)...xs.length
						if xs[j] - xs[i] < (y1 - y0) * 2
							graph[i] << j
						end
					end
				end

				Oversegmentation.new(xs, graph)
			end
		end
	end
end
