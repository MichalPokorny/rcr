require_relative '../../../test_helper'
require 'stringio'

module RCR
	module Data
		class IntegerRawDatasetTest < Test::Unit::TestCase
			class MockDataString
				def initialize(string)
					@string = string
				end

				attr_reader :string

				def ==(other)
					@string == other.string
				end

				def to_raw_data()
					@string
				end

				def self.from_raw_data(data)
					self.new(data)
				end
			end

			def setup
			end

			def test_idempotency
				io = StringIO.new
				data = make_data
				dataset = IntegerRawDataset.new(data)
				dataset.write(io)

				io_in = StringIO.new(io.string)
				dataset2 = IntegerRawDataset.read(io_in, MockDataString)

				assert dataset.keys == dataset2.keys, "dataset keys not equal"
				assert dataset == dataset2, "datasets not equal"
			end

			private
			def make_data
				rnd = Random.new(1234)
				Hash[(0..10).map {
					[rnd.rand(10000), (1..rnd.rand(10)).map { |i| MockDataString.new("data_#{i}_#{rnd.rand(100)}") }]
				}]
			end

			public
			def test_double_loading_gives_same_result
				path = File.join(TEST_DATA_PATH, "dataset_double_load")

				data = make_data
				dataset = IntegerRawDataset.new(data)
				dataset.save(path)

				dataset2 = Data::IntegerRawDataset.load(path, MockDataString)
				dataset3 = Data::IntegerRawDataset.load(path, MockDataString)

				assert dataset == dataset2
				assert dataset2 == dataset3
			end
		end
	end
end
