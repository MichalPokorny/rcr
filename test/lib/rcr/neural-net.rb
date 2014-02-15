require_relative '../../test_helper'

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
			(0..SAMPLES).map {
				inputs = (0...INPUTS).map { rnd.rand }

				[ inputs, test_function(inputs) ]
			}
		end

		public
		def test_can_build_and_train
			data = test_data
			xs, ys = data.map(&:first), data.map { |item| item[1] }

			xs_train, ys_train, xs_test, ys_test = NeuralNet.split_xys(xs, ys, 0.8)
			assert xs_train.size == ys_train.size
			assert xs_test.size == ys_test.size
			assert xs_train.size + xs_test.size == xs.size

			net = NeuralNet.create(num_inputs: INPUTS, hidden_neurons: SHAPE, num_outputs: OUTPUTS)
			assert net.is_a?(NeuralNet)

			GENERATIONS.times do
				net.train_on_xys(xs_train, ys_train)
			end
		end

		private
		def nice_dump(data)
			"[#{data.map { |d| sprintf("%.3f", d) }.join(', ')}]"
		end

		public
		def test_saving_and_loading_gives_same_result
			data = test_data
			xs, ys = data.map(&:first), data.map { |item| item[1] }

			xs_train, ys_train, xs_test, ys_test = NeuralNet.split_xys(xs, ys, 0.8)

			net = NeuralNet.create(num_inputs: INPUTS, hidden_neurons: SHAPE, num_outputs: OUTPUTS)
			assert net.is_a?(NeuralNet)

			GENERATIONS.times do
				net.train_on_xys(xs_train, ys_train)
			end

			path = File.join(TEST_DATA_PATH, "neural_net")
			net.save(path)

			assert File.exist?(path + ".fann") && File.exist?(path + ".net-params")

			net2 = NeuralNet.load(path)

			xs_test.zip(ys_test).each do |xy|
				x, _ = *xy
				# x, y = *xy
				# puts "Input: #{nice_dump(x)}, out before: #{nice_dump(net.run(x))}, out after: #{nice_dump(net2.run(x))}, expect: #{nice_dump(y)}"
				assert_equal net.run(x), net2.run(x)
			end
		end
	end
end
