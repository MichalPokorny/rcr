require 'kgr/logging'

module KGR
	module Data
		class IntegerRawDataset
			include Logging

			def initialize(data = nil)
				@data = data
			end

			def [](key)
				@data[key]
			end

			def keys
				@data.keys
			end

			def delete(*args)
				@data.delete(*args)
			end

			def write(io)
				@data.keys.each { |key|
					raise ArgumentError, "Invalid key class: #{key.class}" unless key.is_a? Fixnum
					
					item_count = @data[key].count
					bytes = [ key, item_count ].pack("qq")
					io.write(bytes)

					@data[key].each { |item|
						raise ArgumentError, "Invalid item class: #{item.class}" unless item.respond_to?(:to_raw_data)
						data = item.to_raw_data
						size = data.size
						bytes = [ size ].pack("Q")
						io.write(bytes)
						io.write(data)
					}
				}
			end

			def save(filename)
				File.open(filename, "wb") do |file|
					write(file)
				end
			end

			def self.read(io, klass)
				data = {}

				until io.eof?	
					bytes = io.read(16)
					key, item_count = bytes.unpack("qq")
					log "Key #{key}, #{item_count} items"

					raise if data.key?(key)
					data[key] = []

					item_count.times { |i|
						bytes = io.read(8)
						r = bytes.unpack("Q")
						size = r.first
						item = klass.from_raw_data(io.read(size))
						data[key] << item
					}
				end

				self.new(data)
			end

			def self.load(filename, klass = KGR::Data::Image)
				File.open(filename, "rb") do |file|
					return self.read(file, klass)
				end
			end
		end
	end
end
