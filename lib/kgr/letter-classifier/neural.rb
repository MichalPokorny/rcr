require 'yaml'
require 'kgr/data/image'
require 'kgr/data/integer_raw_dataset'
require 'kgr/neural-net'
require 'ruby-fann'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data
				dir = "/home/prvak/rocnikac/kgr-data"

				puts "TODO: prepare letter classifier data"

				data_by_letter = {}

				Dir["#{dir}/letter/*"].each do |sample_dir|
					puts "TODO: prepare #{sample_dir} data"
					
					desc = YAML.load_file(File.join(sample_dir, "data.yml"))

					# Create list of letter codes contained in the file.
					letters = []
					desc["segments"].each do |segment|
						letters += (segment["first"]..segment["last"]).to_a.map(&:ord)
					end

					image = Data::Image.load(File.join(sample_dir, "data.png"))

					data = image.crop_by_columns(letters.count, desc["cell_height"])

					# Make it so that the data is indexed by letter.
					data.each_index do |index|
						letter = letters[index]
						unless data_by_letter.key?(letter)
							data_by_letter[letter] = []
						end

						data_by_letter[letter] += data[index]
					end
				end

				dataset = Data::IntegerRawDataset.new(data_by_letter)
				dataset.save("/home/prvak/rocnikac/kgr-prepared/letter.bin")
			end

			def self.shuffle_xys(xs, ys)
				indexes = (0...xs.length).to_a.shuffle
				[ indexes.map { |i| xs[i] }, indexes.map { |i| ys[i] } ]
			end

			def self.dataset_to_xys(dataset)
				min, max = dataset.keys.min, dataset.keys.max

				inputs = []
				outputs = []

				dataset.keys.each { |x|
					output_select = (0..(max-min)).to_a.map { |i| (i == x - min) ? 1 : 0 }
					# puts "#{x} ==> #{output_select}"

					dataset[x].each { |input|
						inputs << input
						outputs << output_select
						puts "#{self.data_to_string(input)} => #{output_select}"
					}
				}

				p(inputs)

				[ inputs, outputs ]
			end

			# Z formatu { klic => { vstupy neuronove site co maji dat tenhle vysledek
			# } } do formatu [ vstupy neuronky ], [ vystupy neuronky ], ...
			def self.dataset_to_train_data(dataset)
				inputs, outputs = self.dataset_to_xys(dataset)
				RubyFann::TrainData.new(inputs: inputs, desired_outputs: outputs)
			end

			def self.data_inputs_size(data)
				p data.keys.first

				inputs = data[data.keys.first]

				puts "inputs first: #{inputs.first.inspect}"

				size = inputs.first.size

				size
			end

			def train
				puts "Training neural net for letters"

				data = {}
				
				# TODO: bude jeste orezavani bile. A taky normalizace kontrastu. Fuj.
				dataset = Data::IntegerRawDataset.load("/home/prvak/rocnikac/kgr-prepared/letter.bin")
				dataset.keys.each { |key|
					data[key] = dataset[key].map { |item|
						NeuralNet.image_to_data(item)
					}
				}

				# Restrict keys to A..Z
				keys = data.keys
				for k in keys
					unless ('0'..'9').include?(k.chr)
						data.delete k
					end
				end

				# TODO: move to NeuralNet

				# TODO: resize all images to same size and so on

				@min, @max = data.keys.min, data.keys.max
				train_data = self.class.dataset_to_train_data(data)
				num_inputs = self.class.data_inputs_size(data)
				num_outputs = @max - @min + 1

				train_data.save('letter.train')

				puts "num_inputs: #{num_inputs}"
				puts "num_outputs: #{num_outputs}"

				# TODO assert same size
				@fann = RubyFann::Standard.new(num_inputs: num_inputs, hidden_neurons: [ 64, 26 ], num_outputs: num_outputs)

				@fann.init_weights(train_data)
				@fann.set_train_error_function(:linear)

				xs, ys = self.class.dataset_to_xys(data)

				10.times {
					xs, ys = self.class.shuffle_xys(xs, ys)
					100.times {
						puts "..."
						(0...xs.length).each { |i|
							@fann.train(xs[i], ys[i])
						}
					}

					good, total = 0, 0
					data.keys.each { |key|
						data[key].each { |item|
							print "actually #{key.chr}: "
							good += 1 if classify_data(item) == key
							total += 1
						}
					}
				}

				#@fann.cascadetrain_on_data(train_data, (16*16), 10, 0.05)
				#puts "Reached MSE: #{@fann.test_data(train_data)}"
			end

			def save(filename)
				@fann.save(filename)
				puts "saving min, max: #{@min} #{@max}"
				File.open "#{filename}_mp", "w" do |file|
					# TODO: rovnou cela funkce mezi kodem znaku a kodem v neuronce!!!!
					file.puts @min
					file.puts @max
				end
			end

			def initialize(fann = nil, min = nil, max = nil)
				@fann = fann
				@min = min
				@max = max
			end

			def self.load(filename)
				min = 0
				max = 0
				File.open "#{filename}_mp", "r" do |file|
					lines = file.readlines
					min = lines.shift.to_i
					max = lines.shift.to_i
				end
				puts "loaded min, max: #{min} #{max}"
				self.new(RubyFann::Standard.new(filename: filename), min, max)
			end

			def classify(image) # Expectation: image is the same size as trainer inputs
				classify_data(NeuralNet.image_to_data(image))
			end

			def self.data_to_string(data)
				data.map { |x| (x * 15).to_i.to_s(16) }.join
			end

			def classify_data(data)
				puts self.class.data_to_string(data)

				result = @fann.run(data)
				
				letter = result.index(result.max)

				puts "seen as #{(letter + @min).chr}: #{result.map{|x| "%.2f" % x}.join(" ")}"
				letter	
			end
		end
	end
end
