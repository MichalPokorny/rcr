require 'rcr/data/image'
require 'rcr/heuristic-oversegmenter/oversegmentation'

# Oversegments by X coordinates of contiguous blocks and by a regular
# interval.
class RCR::HeuristicOversegmenter::StupidRegular
	def initialize
	end

	# Returns list of X coordinates to oversegment the image at.
	def oversegment(image, letter_classifier)
		# TODO: mayhaps move the method somewhere else?
		parts = WordSegmentator.segment_into_contiguous_parts(image)
		return [] if parts.empty?

		xs = parts.map(&:x0) + parts.map(&:x1)
		x0, x1 = xs.min, xs.max
		y0, y1 = parts.map(&:y0).min, parts.map(&:y1).max
		step = (y1 - y0) / 4

		xs += (x0..x1).step(step).to_a
		xs.sort!.uniq!

		puts "building stupidly: #{xs}"

		Oversegmentation.build_from_xs(image, letter_classifier, xs)
	end
end
