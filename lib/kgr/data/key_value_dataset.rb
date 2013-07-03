module KGR
	module Data
		class IntegerImageDataset
			def initialize(data = nil)
				@data = data
			end

			def [](key)
				@data[key]
			end

			def save(filename)
				File.open(filename, "wb") do |file|
					@data.keys.each { |key|
						raise ArgumentError, "Invalid key class: #{key.class}" unless key.is_a? Fixnum
						
						file.write([ key, @data[key].count ].pack("q"))

						@data[key].each { |item|
							raise ArgumentError, "Invalid item class: #{item.class}" unless item.is_a? KGR::Data::Image
							data = item.to_rgba_stream
							file.write([ data.size ].pack("Q"))
							file.write(data)
						}
					}
				end
			end

			def self.load(filename)
				data = {}
				File.open(filename, "rb") do |file|
					until file.eof?	
						key, item_count = file.read(16).unpack("q")

						raise if data.key?(key)
						data[key] = []

						item_count.times {
							size = file.read(8).unpack("Q")
							item = ChunkyPNG::Image.from_rgba_stream(file.read(size))
							data[key] << item
						}
					end
				end

				self.new(data)
			end
		end
	end
end
