require_relative '../../../test_helper'
require 'stringio'

module KGR
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

			def assert_dataset_same(a, b)
				assert a.keys == b.keys
				a.keys.each do |x|
					assert a[x] == b[x]
				end
			end

			def test_idempotency
				io = StringIO.new
				data = {
					123 => (1..10).map { |i| MockDataString.new("data_#{i}_123") },
					456 => (1..20).map { |i| MockDataString.new("data_#{i}_456") },
				}
				dataset = IntegerRawDataset.new(data)
				dataset.write(io)

				io_in = StringIO.new(io.string)
				dataset2 = IntegerRawDataset.read(io_in, MockDataString)

				assert_dataset_same dataset, dataset2
			end
		end
	end
end
