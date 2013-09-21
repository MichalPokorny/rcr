require 'kgr/heuristic-oversegmenter/stupid'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'

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
				best_path = oversegmentation.best_path(self)
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
