require 'test/unit'
require 'rcr'
require 'rcr/markov_chain'
require 'rcr/language_model/markov_chains'
require 'rcr/data/image'
require 'rcr/word_segmentator'
require 'rcr/letter_classifier/neural'
require 'rcr/heuristic_oversegmenter/local_minima'

TEST_DATA_PATH = File.join(File.dirname(__FILE__), '..', 'test-data')
