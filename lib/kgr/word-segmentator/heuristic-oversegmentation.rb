require 'kgr/heuristic-oversegmenter/stupid'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'

# TODO: make oversegmenter settable

# TODO: alternative edges -- pick the one that hungrily fits the Markov chain * the score the best?
# TODO: Markov chain modeling is probably horribly wrong!

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

			def initialize(oversegmenter, letter_classifier, language_model)
				@oversegmenter = oversegmenter # HeuristicOversegmenter::Stupid.new
				@letter_classifier = letter_classifier
				@language_model = language_model
			end

			def calculate_score(context, image, x0, x1)
				img = image.crop(x0, 0, x1 - x0, image.height)
				# TODO: what about other tips?
				result, score = @letter_classifier.classify_with_score(img) # first returned value: result

				result = result.chr

				lm_score =
					if @language_model
						@language_model.score(context, result)
					else
						1
					end

				lm_msg =
					if @language_model
						sprintf(" lms=%.2f context=#{context.join ''}", lm_score)
					else
						""
					end

				puts sprintf("#{x0}..#{x1}: score=%.2f result=#{result}#{lm_msg}", score)

				[ result, score * lm_score ]
			end

			def show_oversegmentation(image)
				oversegmentation = @oversegmenter.oversegment(image)
				xs = oversegmentation.xs
				oversegmentation.xs.each_index do |i|
					image.draw_rectangle!(xs[i], 0, xs[i], image.height, ChunkyPNG::Color.rgb(100, 100, 100))
				end
			end

			def segment(image)
				oversegmentation = @oversegmenter.oversegment(image)

				# Viterbi algorithm
				scores = {}
				scores[0] = 1
				path = {}

				context = {}
				context[0] = []

				puts "oversegmentation xs: #{oversegmentation.xs}"
				puts "graph: #{oversegmentation.graph}"

				oversegmentation.xs.each_index do |i|
					for j in oversegmentation.graph[i]
						result, edge_score = calculate_score(context[i], image, oversegmentation.xs[i], oversegmentation.xs[j])
						score = scores[i] * edge_score
						if scores[j].nil? || scores[j] < score
							scores[j], path[j] = score, i 
							context[j] = context[i] + [ result ]
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
