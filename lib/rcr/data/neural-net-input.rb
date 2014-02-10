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

			# Assumes maximum of 1.0
			def to_human_s
				# TODO: move out
				greyscale = %s{.'`,^:";~-_+<>i!lI?/\|()1{}[]rcvunxzjftLCJUYXZO0Qoahkbdpqwm*WMB8&%$#@}

				sq = Math.sqrt(data.size).round
				str = ""
				for row in 0...sq
					for col in 0...sq
						i = row * sq + col
						dp = data[i]
						next unless dp
						raise "datapoint above 1.0 or under 0.0" unless dp >= 0.0 && dp <= 1.0
						index = (dp * (greyscale.size - 1)).round
						gs = greyscale[index]
						str << gs
					end
					str << "\n"
				end

				str
			end
		end
	end
end
