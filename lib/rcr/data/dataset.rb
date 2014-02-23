module RCR
	module Data
		class Dataset
			def initialize(content)
				# TODO: check same type of keys and values
				case content
				when Array
					@content = content
				when Hash
					@content = content.flat_map { |key, values|
						values.map { |value|
							[key, value]
						}
					}
				else raise "Don't know how to make Dataset from #{content.class}."
				end
			end

			def empty?
				@content.empty?
			end

			def shuffle!
				@content.shuffle!
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
				split = (size * threshold).floor
				[self.class.new(@content[0...split]), self.class.new(@content[split...size])]
			end

			def to_xs_ys_arrays
				# XXX
				[@content.map(&:last), @content.map(&:first)]
			end

			def restrict_keys(keys)
				self.class.new(@content.select { |pair|
					keys.include?(pair.first)
				})
			end

			def transform_keys
				self.class.new(@content.map { |pair| [yield(pair.first), pair.last] })
			end

			def to_fann_dataset
				xs, ys = to_xs_ys_arrays
				RubyFann::TrainData.new(inputs: xs, desired_outputs: ys)
			end
		end
	end
end
