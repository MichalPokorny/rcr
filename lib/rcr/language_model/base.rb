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
			def most_likely_words(letter_hypotheses, want_words: 100)
				last_most_likely_words = { 1.0 => "" }

				# TODO: probably doesn't actually work all that well... !!!!!
				# TODO: ALE TO BY ZNAMENALO ZE MAM BLBE VITERBIHO I JINDE!

				letter_hypotheses.each do |letter_hypothesis|
					# letter hypothesis: hash of letter => score
					best_now = {}

					last_most_likely_words.each do |prefix_probability, prefix|
						scores = score_prefix_continuations(prefix, letter_hypothesis.keys)

						letter_hypothesis.each do |letter, letter_score|
							# puts "Prefix: #{prefix.inspect}"
							posterior_score = letter_score * scores[letter]
							my_score = posterior_score * prefix_probability

							best_now[my_score] = prefix + letter
							# if best.nil? || best_score < my_score
							# 	best, best_score = letter, my_score
							# end
						end
					end

					good_enough = best_now.keys.sort.reverse.take(want_words)
					keep = good_enough.last
					last_most_likely_words = best_now.delete_if { |key, value| key < keep }
				end

				last_most_likely_words
			end

			def most_likely_word(letter_hypotheses)
				result = most_likely_words(letter_hypotheses)
				unless result.empty?
					best = result.keys.sort.reverse.first
					result[best]
				end
			end
		end
	end
end
