module RCR
	module LanguageModel
		class Base
			# Return a score of next letter given a word.
			def score(context, continuation)
				raise "Not implemented."
			end

			# Return the most likely word given a list of letter classification
			# results (array of hashes of letter => score).
			# Default implementation: Viterbi algorithm.
			def most_likely_word(letter_hypotheses)
				best_word_so_far = ""
				letter_hypotheses.each do |letter_hypothesis|
					# letter hypothesis: hash of letter => score

					best, best_score = nil, nil
					letter_hypothesis.each do |letter, letter_score|
						my_score = letter_score * score(best_word_so_far, letter)
						if best.nil? || best_score < my_score
							best, best_score = letter, my_score
						end
					end

					best_word_so_far << best
				end

				best_word_so_far
			end
		end
	end
end
