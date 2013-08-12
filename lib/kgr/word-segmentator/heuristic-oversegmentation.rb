require 'kgr/heuristic-oversegmenter/stupid'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'

# TODO: make oversegmenter settable

module KGR
	module WordSegmentator
		class HeuristicOversegmentation
			def save(filename)
				# stub
			end

			def self.load(filename)
				# stub
				self.new
			end

			def initialize(oversegmenter, letter_classifier)
				@oversegmenter = oversegmenter # HeuristicOversegmenter::Stupid.new
				@letter_classifier = letter_classifier
			end

			def calculate_score(image, x0, x1)
				img = image.crop(x0, 0, x1 - x0, image.height)
				# TODO: what about other tips?
				result, score = @letter_classifier.classify_with_score(img) # first returned value: result

				puts sprintf("#{x0}..#{x1}: score=%.2f result=#{result.chr}", score)

				score
			end

			def segment(image)
				oversegmentation = @oversegmenter.oversegment(image)

				# Viterbi algorithm
				scores = {}
				scores[0] = 1
				path = {}

				puts "xs: #{oversegmentation.xs}"
				puts "graph: #{oversegmentation.graph}"

				oversegmentation.xs.each_index do |i|
					for j in oversegmentation.graph[i]
						score = scores[i] * calculate_score(image, oversegmentation.xs[i], oversegmentation.xs[j])
						if scores[j].nil? || scores[j] < score
							scores[j], path[j] = score, i 
						end
					end
				end
				
				# TODO: mayhaps don't oversegment whole?
				best_path = []
				point = oversegmentation.xs.length - 1
				until point.nil?
					best_path << point
					point = path[point]
				end

				best_path = best_path.map { |i| oversegmentation.xs[i] }.sort

				puts "best path found: #{best_path}"

				boxes = []
				(1...best_path.length).each do |i|
					x0, x1 = best_path[i - 1], best_path[i]
					img = image.crop(x0, 0, x1 - x0, image.height)
					boxes << KGR::Data::SegmentationBox.new(x0, 0, img)
				end
				
				KGR::Data::Segmentation.new(image, boxes)
			end
		end
	end
end
