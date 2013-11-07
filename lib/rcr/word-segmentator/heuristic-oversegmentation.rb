require 'rcr/logging'
require 'rcr/heuristic-oversegmenter/stupid'
require 'rcr/data/segmentation'
require 'rcr/data/segmentation-box'
require 'rcr/data/cropped-imagelike'

# TODO: Markov chain modeling is probably horribly wrong!

module RCR
	module WordSegmentator
		class HeuristicOversegmentation
			include Logging

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
				img = RCR::Data::CroppedImagelike.new(image, x0, x1, 0, image.height)
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

				log sprintf("#{x0}..#{x1}: score=%.2f result=#{result}#{lm_msg}", score)

				[ result, score * lm_score ]
			end

			def show_oversegmentation(image)
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				xs = oversegmentation.xs
				oversegmentation.xs.each_index do |i|
					image.draw_rectangle!(xs[i], 0, xs[i], image.height, ChunkyPNG::Color.rgb(100, 100, 100))
				end
			end

			def find_best_path_of_word(image, word)
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				oversegmentation.best_path_of_word(word)
			end

			def path_to_oversegmentation(image, path)
				boxes = []
				path.each do |edge|
					x0, x1 = edge.x0, edge.x1
					img = image.crop(x0, 0, x1 - x0, image.height)
					boxes << RCR::Data::SegmentationBox.new(x0, 0, img)
				end
				
				RCR::Data::Segmentation.new(image, boxes)
			end

			def segment_for_word(image, word)
				best_path = find_best_path_of_word(image, word)
				log "best path for #{word} found: #{best_path.inspect}"
				if best_path
					path_to_oversegmentation(image, best_path)
				end
			end

			def segment(image)
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				path_to_oversegmentation(image, oversegmentation.best_path)
			end
		end
	end
end
