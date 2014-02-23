require 'rcr/logging'
require 'rcr/data/image'
require 'rcr/heuristic_oversegmenter/oversegmentation'
require 'rcr/word_segmentator'

module RCR
	module HeuristicOversegmenter
		# Oversegments by ink height local minima.
		class LocalMinima
			include Logging

			# Returns list of X coordinates to oversegment the image at.
			# Segments by ink amount.
			def oversegment(image, letter_classifier)
				parts = WordSegmentator.segment_into_contiguous_parts(image)
				return [] if parts.empty?

				xs = parts.map(&:x0) + parts.map(&:x1)
				x0, x1 = xs.min, xs.max
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

				good_minima << x0 << x1
				good_minima.sort!

				log "building from good minima: #{good_minima}"

				Oversegmentation.build_from_xs(image, letter_classifier, good_minima, y0, y1)
			end
		end
	end
end
