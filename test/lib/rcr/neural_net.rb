require_relative '../../test_helper'
require 'rcr/data/dataset'
require 'rcr/data/neural_net_input'

module RCR
	class NeuralNetTest < Test::Unit::TestCase
		private
		INPUTS = 5
		OUTPUTS = 3
		SHAPE = [5, 7, 4]
		GENERATIONS = 100
		SAMPLES = 50

		def test_function(inputs)
			raise unless inputs.size == INPUTS

			[(inputs[0] + inputs[1]) / 2, (inputs[1] + inputs[3] + inputs[4]) / 3, (inputs[2] + inputs[4]) / 2]
		end

		def test_data
			rnd = Random.new(12345)
			Data::Dataset.new(SAMPLES.times.map {
				inputs = (0...INPUTS).map { rnd.rand }
				[Data::NeuralNetInput.new(inputs), test_function(inputs)]
			})
		end

		public
		def test_can_build_and_train
			data = test_data
			xs, ys = data.to_xs_ys_arrays

			train, test = data.split(threshold: 0.8)

			net = NeuralNet.create(num_inputs: INPUTS, hidden_neurons: SHAPE, num_outputs: OUTPUTS)
			assert net.is_a?(NeuralNet)

			GENERATIONS.times do
				net.train(train)
			end
		end

		private
		def nice_dump(data)
			"[#{data.map { |d| sprintf("%.3f", d) }.join(', ')}]"
		end

		public
		def test_saving_and_loading_gives_same_result
			data = test_data
			xs, ys = data.to_xs_ys_arrays

			train, test = data.split(threshold: 0.8)
			xs_train, ys_train = train.to_xs_ys_arrays
			xs_test, ys_test = test.to_xs_ys_arrays

			net = NeuralNet.create(num_inputs: INPUTS, hidden_neurons: SHAPE, num_outputs: OUTPUTS)
			assert net.is_a?(NeuralNet)

			GENERATIONS.times do
				net.train(train)
			end

			path = File.join(TEST_DATA_PATH, "neural_net")
			net.save(path)

			assert File.exist?(path + ".fann") && File.exist?(path + ".net-params")

			net2 = Marshal.load(path)

			xs_test.zip(ys_test).each do |xy|
				x, _ = *xy
				# x, y = *xy
				# puts "Input: #{nice_dump(x)}, out before: #{nice_dump(net.run(x))}, out after: #{nice_dump(net2.run(x))}, expect: #{nice_dump(y)}"
				assert_equal net.run(x), net2.run(x)
			end
		end

		private
		def xor_fn(a, b)
			boolean_a, boolean_b = a > 0.5, b > 0.5

			da, db = (a-0.5).abs, (b-0.5).abs
			(boolean_a ^ boolean_b) ? (0.5 + (da + db) / 2) : (0.5 - (da + db) / 2)
		end

		public
		def test_train_xor
			# XOR dataset
			data = 1000.times.map {
				a, b = rand, rand
				[[a, b], xor_fn(a, b)]
			}

			dataset = RCR::Data::Dataset.new(data).
				transform_inputs { |x| RCR::Data::NeuralNetInput.new(x.map(&:to_f)) }.
				transform_expected_outputs { |y| [y.to_f] }

			net = RCR::NeuralNet.create(num_inputs: 2, num_outputs: 1,
				hidden_neurons: [4, 4])

			100.times { net.train(dataset) }

			require 'pp'

			output = net.run(RCR::Data::NeuralNetInput.new([0.9, 0.8]))
			assert output[0] < 0.3 # true

			output = net.run(RCR::Data::NeuralNetInput.new([0.1, 0.9]))
			assert output[0] > 0.7 # true
		end
	end
end
