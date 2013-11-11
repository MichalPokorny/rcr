require 'test/unit'
require 'rcr'
require 'rcr/markov-chain'
require 'rcr/markov-chain-model'
require 'rcr/data/image'
require 'rcr/data/integer_raw_dataset'
require 'rcr/word-segmentator'
require 'rcr/letter-classifier/neural'
require 'rcr/heuristic-oversegmenter/local-minima'

TEST_DATA_PATH = File.join(File.dirname(__FILE__), '..', 'test-data')
