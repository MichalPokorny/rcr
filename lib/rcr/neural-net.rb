require 'ruby-fann'
require 'rcr/data/neural-net-input'
require 'rcr/logging'

#@fann.cascadetrain_on_data(train_data, (16*16), 10, 0.05)

# data, pocet epoch, kazdych X delej vypis, target error
#@fann.train_on_data(train_data, 100, 10, 0.05)

module RCR
	class NeuralNet
		include Logging

		# TODO: contrast normalization

		def self.create(num_inputs: nil, hidden_neurons: [], num_outputs: nil)
			raise ArgumentError if num_inputs.nil? || hidden_neurons.empty? ||
				num_outputs.nil? || num_outputs < 1 || hidden_neurons.any? { |n| n <= 0 } ||
				num_inputs < 1

			log "Num inputs: #{num_inputs}, neurons: #{hidden_neurons.inspect}, outputs: #{num_outputs.inspect}"

			fann = RubyFann::Standard.new(num_inputs: num_inputs, hidden_neurons: hidden_neurons, num_outputs: num_outputs)	

			# This tries some smart algorithm, but it seems to initialize nonsense.
			# @fann.init_weights(train_data)
			fann.randomize_weights(-1.0, 1.0)
			fann.set_train_error_function(:linear)

			self.new(fann, num_inputs, num_outputs)
		end

		def initialize(fann, n_inputs, n_outputs)
			@fann = fann
			@n_inputs = n_inputs
			@n_outputs = n_outputs
		end

		attr_reader :n_inputs

		def train(dataset)
			train_on_xys(*dataset.to_xs_ys_arrays)
		end

		def train_on_xys(xs, ys)
			raise unless xs.length == ys.length

			xs.each_index do |i|
				raise "Input size doesn't match" if xs[i].size != @n_inputs
				raise "Output size doesn't match" if ys[i].size != @n_outputs
				@fann.train(xs[i], ys[i])
			end
		end

		def save(filename)
			log "Saving neural net with #@n_inputs inputs and #@n_outputs outputs"

			# pp @fann.get_neurons
			# @fann.print_connections

			@fann.save(filename + ".fann")
			File.open "#{filename}.net-params", "w" do |file|
				YAML.dump({
					n_inputs: @n_inputs,
					n_outputs: @n_outputs
				}, file)
			end
		end

		def self.load(filename)
			fann_file = "#{filename}.fann"
			log "FANN file: #{fann_file}"
			raise ArgumentError, "FANN file doesn't exist: #{fann_file}" unless File.exist?(fann_file)
			# ??? fann = RubyFann::Standard::new(filename: fann_file)
			fann = RubyFann::Standard.new(filename: fann_file)

			yaml_file = "#{filename}.net-params"
			log "YAML file: #{yaml_file}"
			raise ArgumentError, "YAML file doesn't exist: #{yaml_file}" unless File.exist?(yaml_file)
			params = YAML.load_file(yaml_file)

			log "Loaded neural net with #{params[:n_inputs]} inputs and #{params[:n_outputs]} outputs"

			# pp fann.get_neurons
			# fann.print_connections

			self.new(fann, params[:n_inputs], params[:n_outputs])
		end

		def run(x)
			@fann.run(x)
		end
	end
end
