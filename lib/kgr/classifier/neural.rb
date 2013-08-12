require 'kgr/neural-net'
require 'kgr/data/neural-net-input'

module KGR
	module Classifier
		class Neural
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
				sum = result.inject(&:+)
				score = if sum == 0 # TODO: isn't that too much?
					0.00001
				else
					max / sum
				end
				
				[ @classes[result.index(max)], score ]
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
					output_select = @classes.map { |l| (l == x) ? 1 : 0 }
					# puts "dl: #{@classes.join ' '}"
					# puts "#{x} ==> #{output_select}"

					dataset[x].each { |input|
						raise unless input.is_a? Data::NeuralNetInput
						inputs << input.data
						outputs << output_select
						# puts "#{self.class.data_to_string(input)} => #{output_select}"
					}
				}

				# p(inputs)

				[ inputs, outputs ]
			end

			public
			# Hash: class => [ inputs that have this class ]
			def train(dataset, generations: 100, dataset_split: 0.8)
				log = File.open "train.log", "w"

				xs, ys = NeuralNet.shuffle_xys(*dataset_to_xys(dataset))
				xs_train, ys_train, xs_test, ys_test = NeuralNet.split_xys(xs, ys, dataset_split)

				puts "Training neural classifier. #{xs_train.length} training inputs, #{xs_test.length} testing inputs."

				generations.times { |round|
					@net.train_on_xys(xs_train, ys_train)

					good, total = 0, 0
					(0...xs_test.length).each { |i|
						good += 1 if classify(xs_test[i]) == @classes[ys_test[i].index(ys_test[i].max)]
						total += 1
					}
					puts "After round #{round + 1} out of #{generations}: good: #{good}, total: #{total} (%.2f%%)" % [ (good.to_f / total.to_f) * 100 ]
					log.puts "#{round + 1}\t#{good}\t#{total}\t#{good.to_f / total.to_f}"
					log.flush
				}

				log.close
			end
		end
	end
end
