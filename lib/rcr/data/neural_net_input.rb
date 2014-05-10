module RCR
	module Data
		class NeuralNetInput
			def initialize(data)
				raise "Trying to construct neural net input from something other than an array" unless data.is_a? Array
				@data = data

				data.each { |item|
					raise "Neural net inputs must all be floats" unless item.is_a?(Float)
					# TODO: check 0-1 range?
				}
			end

			def self.concat(*inputs)
				self.new(inputs.map(&:data).flatten)
			end

			def to_raw_data
				raw = ""
				raw << [@data.size].pack("Q")
				raw << @data.pack("D" * @data.size)

				raw
			end

			def self.from_raw_data(data)
				size = data.unpack("Q").first
				self.new(data[8...(data.size)].unpack("D" * size))
			end

			def size
				data.size
			end

			def ==(other)
				raise unless other.is_a?(NeuralNetInput)
				data == other.data
			end

			attr_reader :data
		end
	end
end
