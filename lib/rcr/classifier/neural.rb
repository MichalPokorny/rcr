require 'rcr/classifier/base'
require 'rcr/neural_net'
require 'rcr/data/neural_net_input'
require 'rcr/logging'

module RCR
	module Classifier
		class Neural < Base
			def initialize(net = nil, classes = nil)
				super(classes)
				@net = net
			end

			MARSHAL_ID = self.name
			include Marshal

			def self.load_internal(filename)
				opts = YAML.load_file("#{filename}.classifier-opts")
				self.new(Marshal.load("#{filename}.net"), opts[:classes])
			end

			def save_internal(filename)
				@net.save("#{filename}.net")
				File.open("#{filename}.classifier-opts", "w") do |file|
					YAML.dump({
						classes: @classes
					}, file)
				end
			end

			def self.create(num_inputs: nil, hidden_neurons: nil, classes: nil)
				classes = classes.to_a
				raise ArgumentError, "Empty class list given to classifier" if classes.empty?
				net = NeuralNet.create(num_inputs: num_inputs, hidden_neurons: hidden_neurons, num_outputs: classes.size)
				self.new(net, classes)
			end

			# Returns hash { class => score }
			# TODO: perhaps another scoring mechanism?
			def classify_with_alternatives(x)
				result = @net.run(x)
				alts = {}

				if result.min == result.max
					log "No differences seen in neural net outputs, returning uniform distribution."
					result.map! { 1.0 }
				else
					min_nonzero = result.select { |i| i > 0 }.min / 100

					@classes.each.with_index do |c, i|
						alts[c] = min_nonzero + result[i] # Stupid smoothing.
					end
				end

				sum = alts.values.inject(&:+)
				alts.keys.each { |k| alts[k] /= sum }

				alts
			end

			# TODO: this is a hack that expect data between 0 and 1!
			def self.data_to_string(data)
				data.map { |x| (x * 15).to_i.to_s(16) }.join
			end

			private
			def output_select(x)
				raise "#{x} is not a class (classes: #{@classes.inspect})" unless @classes.include?(x)
				@classes.map { |l| (l == x) ? 1 : 0 }
			end

			def output_select_empty
				@classes.map { 0 }
			end

			#public
			#def untrain(inputs, generations: 100, logging: false)
			#	xs, ys = inputs.map(&:data), inputs.map { output_select_empty }
			#	with_logging_set(logging) {
			#		log "Untraining neural classifier."
			#		generations.times { |round|
			#			log "Round #{round}."
			#			@net.train_on_xys(xs, ys)
			#		}
			#	}
			#end
			public

			# Hash: class => [inputs that have this class]
			def train(dataset, generations: nil, dataset_split: 0.8, logging: false)
				raise "Wrong dataset type: #{dataset.class}" unless dataset.is_a? RCR::Data::Dataset

				with_logging_set(logging) {
					train_log = File.open "train.log", "w"

					train, test = dataset.shuffle!.split(threshold: dataset_split)

					train = train.transform_expected_outputs { |key| output_select(key) }

					log "Training neural classifier. #{train.size} training inputs, #{test.size} testing inputs."

					if train.empty? || test.empty?
						raise ArgumentError, "Empty testing or training dataset given. Give me more data."
					end

					(generations || 1000).times { |round|
						@net.train(train.shuffle!)

						e = evaluate(test)
						log "After round #{round + 1}/#{generations}: %.2f%% on test (%.2f%% on all inputs)" % [e, evaluate(dataset)]
						train_log.puts("#{round + 1}\t%.2f" % e)
						train_log.flush
					}

					train_log.close

					log "Final score on whole dataset: %.2f%%" % evaluate(dataset)
				}
			end
		end
	end
end
