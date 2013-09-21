require 'kgr/data/image'
require 'kgr/heuristic-oversegmenter/oversegmentation'

module KGR
	module HeuristicOversegmenter
		# Oversegments by ink height local minima.
		class LocalMinima
			def initialize
			end

			# Returns list of X coordinates to oversegment the image at.
			# Segments by ink amount.
			def oversegment(image)
				parts = WordSegmentator.segment_into_continuous_parts(image)
				return [] if parts.empty?

				xs = parts.map(&:x0) + parts.map(&:x1)
				#x0, x1 = xs.min, xs.max
				y0, y1 = parts.map(&:y0).min, parts.map(&:y1).max

				ink_amounts = (0...image.width).map { |x|
					(0...image.height).map { |y|
						r, g, b = image[x, y]
						(255 - r) + (255 - g) + (255 - b)
					}.inject(&:+)
				}

				minima = (1...image.width-1).select { |x|
					ink_amounts[x - 1] < ink_amounts[x] && ink_amounts[x] < ink_amounts[x + 1]
				}

				good_minima = []
				(0...minima.length).map { |i|
					if minima[i - 1] < minima[i] - 1
						last = minima[i]
						while minima.include?(last)
							last += 1
						end
						if last - minima[i] > 3
							good_minima << (last + minima[i]) / 2
						end
						good_minima << minima[i]
						good_minima << last if last - minima[i] > 2
					end
				}

				good_minima.sort!
				
				xs = good_minima

				graph = {}
				xs.each_index do |i|
					graph[i] = []
					# TODO: Stupid. Stupid. Stupid. Stupid.
					for j in (i+1)...xs.length
						if xs[j] - xs[i] < (y1 - y0) * 2
							graph[i] << j
						end
					end
				end

				Oversegmentation.new(good_minima, graph)
			end
		end
	end
end
