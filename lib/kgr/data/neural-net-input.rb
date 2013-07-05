module KGR
	module Data
		class NeuralNetInput
			def initialize(data)
				raise unless data.is_a? Array
				@data = data

				data.each { |item|
					raise unless item.is_a? Float
				}
			end

			def to_raw_data
				raw = ""
				raw << [ @data.size ].pack("Q")
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

			attr_reader :data
		end
	end
end
