require 'rcr/logging'
require 'rcr/data/segmentation'
require 'rcr/data/segmentation_box'
require 'rcr/data/cropped_imagelike'

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
				@oversegmenter = oversegmenter
				@letter_classifier = letter_classifier
				@language_model = language_model
			end

			def calculate_score(context, image, x0, x1)
				img = RCR::Data::CroppedImagelike.new(image, x0, x1, 0, image.height)
				# TODO: what about other tips?
				result, score = @letter_classifier.classify_with_score(img) # first returned value: result

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

				[result, score * lm_score]
			end

			def show_oversegmentation(image, color: ChunkyPNG::Color.rgb(200, 200, 200))
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				xs = oversegmentation.xs
				oversegmentation.xs.each_index do |i|
					image.draw_rectangle!(xs[i], 0, xs[i], image.height, color)
				end
			end

			def find_best_path_of_word_with_score(image, word)
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				oversegmentation.best_path_of_word_with_score(word)
			end

			def path_to_segmentation(image, path)
				boxes = []
				path.each do |edge|
					x0, x1 = edge.x0, edge.x1
					img = image.crop(x0, 0, x1 - x0, image.height)
					boxes << RCR::Data::SegmentationBox.new(x0, 0, img)
				end
				
				RCR::Data::Segmentation.new(image, boxes)
			end

			def segment_for_word(image, word)
				segment_for_word_with_score(image, word).first
			end

			def segment_for_word_with_score(image, word)
				best_path, score = *find_best_path_of_word_with_score(image, word)
				log "best path for #{word} found: #{best_path.inspect}"
				if best_path
					[ path_to_segmentation(image, best_path), score ]
				end
			end

			def segment(image)
				segment_with_score(image)[0]
			end

			def segment_with_score(image)
				oversegmentation = @oversegmenter.oversegment(image, @letter_classifier)
				path, score = *oversegmentation.best_path_with_score
				[ path_to_segmentation(image, path), score ]
			end
		end
	end
end
