module KGR
	module Data
		class IntegerRawDataset
			def initialize(data = nil)
				@data = data
			end

			def [](key)
				@data[key]
			end

			def write(io)
				@data.keys.each { |key|
					raise ArgumentError, "Invalid key class: #{key.class}" unless key.is_a? Fixnum
					
					io.write([ key, @data[key].count ].pack("q"))

					@data[key].each { |item|
						raise ArgumentError, "Invalid item class: #{item.class}" unless item.respond_to?(:to_raw_data)
						data = item.to_raw_data
						io.write([ data.size ].pack("Q"))
						io.write(data)
					}
				}
			end

			def save(filename)
				File.open(filename, "wb") do |file|
					write(file)
				end
			end

			def self.read(io)
				data = {}

				until io.eof?	
					key, item_count = io.read(16).unpack("q")

					raise if data.key?(key)
					data[key] = []

					item_count.times {
						size = io.read(8).unpack("Q")
						item = Image.from_raw_data(io.read(size))
						data[key] << item
					}
				end

				self.new(data)
			end

			def self.load(filename)
				File.open(filename, "rb") do |file|
					return self.read(file)
				end
			end
		end
	end
end
