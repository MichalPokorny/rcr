require 'rcr/neural-net'
require 'rcr/data/neural-net-input'
require 'rcr/logging'

module RCR
	module Classifier
		class Neural
			include Logging
			
			def initialize(net = nil, classes = nil)
				@net = net
				@classes = classes
			end

			def self.load(filename)
				opts = YAML.load_file "#{filename}.classifier-opts"
				self.new(NeuralNet.load(filename), opts[:classes])
			end

			def save(filename)
				@net.save(filename)
				File.open "#{filename}.classifier-opts", "w" do |file|
					YAML.dump({
						classes: @classes
					}, file)
				end
			end

			def self.create(num_inputs: nil, hidden_neurons: [], classes: [])
				raise ArgumentError if classes.empty? || !classes.is_a?(Array)
				net = NeuralNet.create(num_inputs: num_inputs, hidden_neurons: hidden_neurons, num_outputs: classes.size)
				self.new(net, classes)
			end

			def classify(x)
				result = @net.run(x)
				@classes[result.index(result.max)]
			end

			def classify_with_score(x)
				result = @net.run(x)
				max = result.max

				# Former variant (not resistant to guessing):
				#
				# This is probably broken. Just because a neural network fires in
				# only one node doesn't mean that it's sure of the result.
				#
				sum = result.inject(&:+)
				score = if sum == 0 # TODO: isn't that too much?
					log "No outputs fired, classifying with score epsilon."
					0.00000001
				else
					max / sum
				end

				#score = max / sum

				[ @classes[result.index(max)], score ]
			end

			# Returns hash { class => score }
			# TODO: perhaps another scoring mechanism?
			def classify_with_alternatives(x)
				result = @net.run(x)
				alts = {}
				sum = result.inject(&:+)
				
				min_nonzero = (result.select { |i| i > 0 }.min) || 0.0000001

				if sum == 0
					log "No outputs fired, returning empty distribution."
					{}
				end

				@classes.each_index do |i|
					alts[@classes[i]] = 
						# Stupid smoothing.
						(min_nonzero + result[i]) / (sum + min_nonzero * result.size)
				end
				alts
			end

			# TODO: this is a hack that expect data between 0 and 1!
			def self.data_to_string(data)
				data.map { |x| (x * 15).to_i.to_s(16) }.join
			end

			private
			def dataset_to_xys(dataset)
				inputs = []
				outputs = []

				dataset.keys.each { |x|
					dataset[x].each { |input|
						raise "Dataset isn't made of entries of type Data::NeuralNetInput" unless input.is_a? Data::NeuralNetInput
						inputs << input.data
						outputs << output_select(x)
					}
				}

				[ inputs, outputs ]
			end

			# Pass nil to get zeroes.
			def output_select(x)
				@classes.map { |l| (l == x) ? 1 : 0 }
			end

			public
			def untrain(inputs, generations: 100, logging: false)
				xs, ys = inputs.map(&:data), inputs.map { output_select(nil) }
				with_logging_set(logging) {
					log "Untraining neural classifier."
					generations.times { |round|
						log "Round #{round}."
						@net.train_on_xys(xs, ys)
					}
				}
			end

			private
			def evaluate_on_xys(xs, ys)
				raise "Incompatible sizes of xs and ys to evaluate" if xs.size != ys.size
				good, total = 0, 0
				(0...xs.length).each { |i|
					if classify(xs[i]) == @classes[ys[i].index(ys[i].max)]
						good += 1
					else
						# puts "f: got:#{classify(xs[i])} != expect:#{@classes[ys[i].index(ys[i].max)]}"
					end
					total += 1
				}
				#puts
				good.to_f * 100 / total
			end

			public
			def evaluate(dataset)
				xs, ys = *dataset_to_xys(dataset)
				evaluate_on_xys(xs, ys)
			end

			# Hash: class => [ inputs that have this class ]
			def train(dataset, generations: 100, dataset_split: 0.8, logging: false)
				with_logging_set(logging) {
					train_log = File.open "train.log", "w"

					xs, ys = NeuralNet.shuffle_xys(*dataset_to_xys(dataset))
					xs_train, ys_train, xs_test, ys_test = NeuralNet.split_xys(xs, ys, dataset_split)

					log "Training neural classifier. #{xs_train.length} training inputs, #{xs_test.length} testing inputs."

					generations.times { |round|
						@net.train_on_xys(xs_train, ys_train)

						e = evaluate_on_xys(xs_test, ys_test)
						log "After round #{round + 1}/#{generations}: %.2f%% (%.2f%% on all inputs)" % [ e, evaluate_on_xys(xs, ys) ]
						train_log.puts "#{round + 1}\t%.2f" % [ e ]
						train_log.flush
					}

					train_log.close

					log "Final score on whole dataset: %.2f%%" % evaluate(dataset)
				}
			end
		end
	end
end
