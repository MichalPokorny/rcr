require 'rcr/data/neural_net_input'

module RCR
	module Data
		class Dataset
			private
			def check_input_type!
				each do |pair|
					unless pair.first.is_a?(input_type)
						raise "Heterogenous Dataset input types: #{input_type} vs. #{pair.first.class}"
					end
				end
			end

			def check_expected_output_type!
				each do |pair|
					unless pair.last.is_a?(expected_output_type)
						raise "Heterogenous Dataset input types: #{expected_output_type} vs. #{pair.last.class}"
					end
				end
			end

			public
			def initialize(content = [])
				# TODO: check same type of keys and values
				case content
				when Array
					content.each do |pair|
						raise "Array passed, but it doesn't contain pairs" unless pair.size == 2
					end
					@content = content
				when Hash
					@content = content.flat_map { |expected_output, inputs|
						raise "Values of key #{key} are not an array" unless inputs.is_a? Array
						inputs.map { |input|
							[input, expected_output]
						}
					}
				else raise "Don't know how to make Dataset from #{content.class}."
				end

				unless empty?
					check_input_type!
					check_expected_output_type!
				end
			end

			def insert(input, expected_output)
				unless empty?
					raise "Wrong types of new pair" unless input.is_a?(input_type) && expected_output.is_a?(expected_output_type)
				end
				@content << [input, expected_output]
			end

			def empty?
				@content.empty?
			end

			def shuffle!
				@content.shuffle!
				self
			end

			def size
				@content.size
			end

			def each
				if block_given?
					@content.each { |x| yield x }
				else
					@content.each
				end
			end

			def split(threshold: 0.8)
				raise "Threshold expected to be between 0 and 1" unless threshold >= 0 && threshold <= 1
				split = (size * threshold).floor
				[self.class.new(@content[0...split]), self.class.new(@content[split...size])]
			end

			def to_xs_ys_arrays
				[@content.map(&:first), @content.map(&:last)]
			end

			def restrict_expected_outputs(keys)
				self.class.new(@content.select { |pair| keys.include?(pair.last) })
			end

			def restrict_expected_outputs!(keys)
				@content.select! { |pair| keys.include?(pair.last) }
			end

			def transform_expected_outputs
				self.class.new(@content.map { |pair| [pair.first, yield(pair.last)] })
			end

			def transform_inputs
				self.class.new(@content.map { |pair| [yield(pair.first), pair.last] })
			end

			def transform_inputs!
				@content.map! { |pair| [yield(pair.first), pair.last] }
			end

			def to_fann_dataset
				xs, ys = to_xs_ys_arrays
				RubyFann::TrainData.new(inputs: xs, desired_outputs: ys)
			end

			def ==(other)
				return false unless other.is_a? Dataset
				other.to_xs_ys_arrays == to_xs_ys_arrays
			end

			def input_type
				@content.first.first.class
			end

			def expected_output_type
				@content.first.last.class
			end

			def check_types!(input, output)
				unless input_type == input && expected_output_type == output # TODO: inheritance?
					raise "Unexpected dataset types: #{input_type} => #{expected_output_type}, expected #{input} => #{output}"
				end
			end

			def dup
				self.class.new(@content.dup)
			end
		end
	end
end
