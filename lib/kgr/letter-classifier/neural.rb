require 'yaml'
require 'kgr/data/image'
require 'kgr/data/integer_raw_dataset'
require 'kgr/neural-net'
require 'ruby-fann'
require 'fileutils'

module KGR
	module LetterClassifier
		class Neural
			def self.prepare_data
				dir = "/home/prvak/rocnikac/kgr-data"

				data_by_letter = {}

				Dir["#{dir}/letter/*"].each do |sample_dir|
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

			def dataset_to_xys(dataset)
				inputs = []
				outputs = []

				dataset.keys.each { |x|
					output_select = @detected_letters.map { |l| (l == x) ? 1 : 0 }
					puts "dl: #{@detected_letters.join ' '}"
					puts "#{x} ==> #{output_select}"

					dataset[x].each { |input|
						inputs << input
						outputs << output_select
						puts "#{self.class.data_to_string(input)} => #{output_select}"
					}
				}

				p(inputs)

				[ inputs, outputs ]
			end

			# Z formatu { klic => { vstupy neuronove site co maji dat tenhle vysledek
			# } } do formatu [ vstupy neuronky ], [ vystupy neuronky ], ...
			def dataset_to_train_data(dataset)
				inputs, outputs = dataset_to_xys(dataset)
				RubyFann::TrainData.new(inputs: inputs, desired_outputs: outputs)
			end

			def self.data_inputs_size(data)
				p data.keys.first
				inputs = data[data.keys.first]
				puts "inputs first: #{inputs.first.inspect}"
				size = inputs.first.size
				size
			end

			def self.split_xys(xs, ys, split)
				raise unless xs.length == ys.length
				pt = (xs.length * split).floor

				[ xs[0...pt], ys[0...pt], xs[pt...xs.length], ys[pt...ys.length] ]
			end

			def train
				log = File.open "train_log", "w"
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
				allowed = Set.new(('0'..'9').to_a + ('A'..'Z').to_a)
				for k in keys
					unless allowed.include?(k.chr)
						data.delete k
					end
				end

				@detected_letters = allowed.map { |x| x.ord }.to_a

				# TODO: move to NeuralNet

				# TODO: resize all images to same size and so on

				train_data = dataset_to_train_data(data)
				num_inputs = self.class.data_inputs_size(data)
				num_outputs = @detected_letters.size

				train_data.save('letter.train')

				puts "num_inputs: #{num_inputs}"
				puts "num_outputs: #{num_outputs}"

				# TODO assert same size
				@fann = RubyFann::Standard.new(num_inputs: num_inputs, hidden_neurons: [ 128, 80, 60, allowed.size ], num_outputs: num_outputs)

				# This tries some smart algorithm, but it seems to initialize nonsense.
				# @fann.init_weights(train_data)

				@fann.randomize_weights(-1.0, 1.0)
				@fann.set_train_error_function(:linear)

				xs, ys = dataset_to_xys(data)
				xs, ys = self.class.shuffle_xys(xs, ys)

				xs_train, ys_train, xs_test, ys_test = self.class.split_xys(xs, ys, 0.7)

				100.times {
					xs_train, ys_train = self.class.shuffle_xys(xs_train, ys_train)
					(0...xs_train.length).each { |i|
						@fann.train(xs_train[i], ys_train[i])
					}

					good, total = 0, 0
					(0...xs_test.length).each { |i|
						# puts "expect: #{ys[i]}"
						good += 1 if classify_data(xs_test[i]) == ys_test[i].index(ys_test[i].max)
						total += 1
					}
					puts "good: #{good}, total: #{total}"
					log.puts "good: #{good}, total: #{total}"
				}

				#@fann.cascadetrain_on_data(train_data, (16*16), 10, 0.05)

				# data, pocet epoch, kazdych X delej vypis, target error
				#@fann.train_on_data(train_data, 100, 10, 0.05)
			end

			def index_to_letter(index)
				@detected_letters[index]
			end

			def letter_to_index(letter)
				@detected_letters.index(letter)
			end

			def save(filename)
				@fann.save(filename)
				File.open "#{filename}_mp", "w" do |file|
					file.puts @detected_letters.size
					@detected_letters.each do |letter|
						file.puts letter.ord
					end
				end
			end

			def initialize(fann = nil, detected_letters = nil)
				@fann = fann
				@detected_letters = detected_letters
			end

			def self.load(filename)
				detected_letters = []
				File.open "#{filename}_mp", "r" do |file|
					lines = file.readlines
					lines.shift.to_i.times do
						detected_letters << lines.shift.to_i.chr
					end
				end
				self.new(RubyFann::Standard.new(filename: filename), detected_letters)
			end

			def classify(image)
				index = classify_data(NeuralNet.image_to_data(image))

				puts "Result: #{index_to_letter(index)}"
				index
			end

			def self.data_to_string(data)
				data.map { |x| (x * 15).to_i.to_s(16) }.join
			end

			def classify_data(data)
				result = @fann.run(data)
				result.index(result.max)
			end
		end
	end
end
