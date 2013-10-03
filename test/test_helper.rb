require 'test/unit'
require 'kgr'
require 'kgr/markov-chain'
require 'kgr/markov-chain-model'
require 'kgr/data/image'
require 'kgr/data/integer_raw_dataset'
require 'kgr/word-segmentator'
require 'kgr/letter-classifier/neural'

TEST_DATA_PATH = File.join(File.dirname(__FILE__), '..', 'test-data')
